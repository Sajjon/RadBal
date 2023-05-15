//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-14.
//

import Foundation
import SwiftUI
import Backend

enum LoadSource {
	case file(URL)
	case profile(Profile)
	static func report(_ report: Report) -> Self {
		.profile(report.profile)
	}
}

public struct AppView: SwiftUI.View {
	@State var booted: Bool = false
	@State var timeStampedReport: CachedReport? = nil
	@State var loadSource: LoadSource? = nil
	@State var errorMessage: String? = nil
	var isLoading: Bool {
		loadSource != nil
	}
	var report: Report? {
		timeStampedReport?.report
	}
	var lastFetched: Date? {
		timeStampedReport?.timestamp
	}
	
	public init() {}
	var selectFile: Bool {
		if timeStampedReport != nil {
			return false
		}
		if isLoading {
			return false
		}
		return booted
	}
	
	public var body: some SwiftUI.View {
		NavigationStack {
			ScrollView {
				VStack {
					if isLoading {
						Text("Fetching...")
					}
					if let report {
						content(report: report)
					} else if let errorMessage {
						Text("Failed: \(errorMessage)")
					} else if selectFile {
						Text("Select file")
						.fileImporter(
							isPresented: .constant(selectFile),
							allowedContentTypes: [.json]) { result in
								switch result {
								case let .success(fileURL):
									Task {
										await _fetchAndUpdate(fileURL: fileURL)
									}
								case let .failure(error):
									errorMessage = "Failed to open file, error: \(String(describing: error))"
								}
							}
					}
				}
				.onAppear {
					Task {
						await fetchIfNeeded()
						booted = true
					}
				}
				.padding()
			}
			.refreshable {
				await fetchIfNeeded(force: true)
			}
			.navigationTitle(self.report?.name ?? "Select profile")
		}
	}
	
	@ViewBuilder
	func content(report: Report) -> some View {
		if let lastFetched {
			Text("\(lastFetched.secondsAgo) seconds ago")
			#if os(macOS)
			Button("Force fetch") {
				Task {
					await fetchIfNeeded(force: true)
				}
			}
			#endif
		}
		ReportView(report: report)
	}
	
	var reportOrCached: CachedReport? {
		timeStampedReport ?? UserDefaults.standard.cachedReport
	}
	
	private func fetchIfNeeded(force: Bool = false) async {
		guard let reportOrCached else {
			return
		}
		
		timeStampedReport = reportOrCached
		
		if !force && hasRelevantData {
			return // we have data, and it is not to old
		}
		
		// Should update
		await _fetchAndUpdate(report: reportOrCached.report)
	}
	
	private func _fetchAndUpdate(fileURL: URL) async {
		loadSource = .file(fileURL)
		await __fetchUpdate {
			try await Olympia.aggregate(
				fiat: UserDefaults.defaultFiat,
				profileURL: fileURL
			)
		}
	}
	
	
	private func _fetchAndUpdate(report: Report) async {
		loadSource = .report(report)
		await _fetchAndUpdate(profile: report.profile)
	}
	
	private func _fetchAndUpdate(profile: Profile) async {
		loadSource = .profile(profile)
		await __fetchUpdate {
			try await Olympia.aggregate(fiat: UserDefaults.defaultFiat, profile: profile)
		}
	}
	

	
	private func __fetchUpdate(_ fetch: () async throws -> Report) async {
		defer { loadSource = nil }
		do {
			let report = try await fetch()
			let timestamp = Date.now
			let cached = CachedReport(report: report, timestamp: timestamp)
			UserDefaults.standard.saveCached(cached)
			timeStampedReport = cached
			errorMessage = nil
		} catch {
			errorMessage = "Failed fetch or save report, error: \(error)"
		}
	}
	
	var hasRelevantData: Bool {
		guard let timeStampedReport else {
			return false
		}
		return timeStampedReport.timestamp.wasRecent
	}
}

struct FailedToFetchReport: Error {}

extension Date {
	
	var secondsAgo: Int {
		let diffComponents = Calendar.current.dateComponents([.minute, .second], from: self, to: .now)
		return diffComponents.second ?? 0
	}
	
	var wasRecent: Bool {
		secondsAgo < 60
	}
}

enum ReportLoadState {
	case new
	case selectFile
	case loading(URL)
	case loaded(Report)
	case failed(Error)
	var isSelectFile: Bool {
		guard case .selectFile = self else {
			return false
		}
		return true
	}
}

extension Binding {
	func mappingBinding<NewValue>(
		transformGet: @escaping (Value) -> NewValue,
		transformSet: @escaping (NewValue) -> Value
	) -> Binding<NewValue> {
		Binding<NewValue>(
			get: { transformGet(wrappedValue) },
			set: { newValue in wrappedValue = transformSet(newValue) }
		)
	}
}

extension UserDefaults {
	static let defaultFiat: Fiat = .sek
	
	var cachedReport: CachedReport? {
		guard let data = data(forKey: cachedReportKey) else {
			return nil
		}
		let jsonDecoder = JSONDecoder()
		jsonDecoder.dateDecodingStrategy = .iso8601
		return try? jsonDecoder.decode(CachedReport.self, from: data)
	}
	
	func saveCached(_ cachedReport: CachedReport) {
		do {
			let jsonEncoder = JSONEncoder()
			jsonEncoder.dateEncodingStrategy = .iso8601
			let data = try jsonEncoder.encode(cachedReport)
			UserDefaults.standard.setValue(data, forKey: cachedReportKey)
		} catch {
			print("Saved to cache report, error: \(error)")
		}
	}
}

struct CachedReport: Codable {
	let report: Report
	let timestamp: Date

}


let cachedReportKey = "cachedReportKey"
