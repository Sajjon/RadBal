//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-14.
//

import Foundation
import SwiftUI
import Backend

public struct AppView: SwiftUI.View {
	@State var reportState: ReportLoadState = .new
	@State var lastFetched: Date?
	var report: Report? {
		guard case let .loaded(report) = reportState else { return nil }
		return report
	}
	public init() {}
	public var body: some SwiftUI.View {
		NavigationStack {
			ScrollView {
				VStack {
					switch reportState {
					case .new:
						Button("Select file") {
							reportState = .selectFile
						}
					case .selectFile:
						Text("Selecting file...")
							.fileImporter(
								isPresented: .init(projectedValue: $reportState.mappingBinding(
									transformGet: { $0.isSelectFile },
									transformSet: { isSelectFile in
										return isSelectFile ? .selectFile : .new
									})),
								allowedContentTypes: [.json]) { result in
									switch result {
									case let .success(fileULR):
										reportState = .loading(fileULR)
									case let .failure(error):
										reportState = .failed(error)
									}
								}
					case let .loaded(report):
						content(report: report)
					case let .loading(fileURL):
						VStack {
							Text("Updating...")
							ProgressView()
							contentOrEmpty
						}
						.task {
							await _fetchAndUpdate(fileURL: fileURL)
						}
					case let .failed(error):
						Text("Failed to load: \(String(describing: error))")
					}
				}
				.onAppear {
					Task {
						await fetchIfNeeded()
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
	var contentOrEmpty: some View {
		if let report {
			content(report: report)
		}
	}
	
	@ViewBuilder
	func content(report: Report) -> some View {
		if let lastFetched {
			Text("\(lastFetched.secondsAgo) seconds ago")
		}
		ReportView(report: report)
	}
	
	

	private func fetchIfNeeded(force: Bool = false) async {
		if !force && hasRelevantData {
			return // we have data, and it is not to old
		}
		
		if let cachedReport = UserDefaults.standard.cachedReport {
			reportState = .loaded(cachedReport.report)
			lastFetched = cachedReport.timestamp
			if force || !cachedReport.timestamp.wasRecent {
				// was old, refetch
				await _fetchAndUpdate(report: cachedReport.report)
			}
		} else {
			switch reportState {
			case let .loaded(report):
				if force || lastFetched?.wasRecent == false {
					// was old, fefetch
					await _fetchAndUpdate(report: report)
				}
			default:
				break
			}
		}


	}
	
	private func _fetchAndUpdate(fileURL: URL) async {
		await __fetchUpdate {
			try await Olympia.aggregate(
				fiat: UserDefaults.defaultFiat,
				profileURL: fileURL
			)
		}
	}
	
	
	private func _fetchAndUpdate(report: Report) async {
		await _fetchAndUpdate(profile: report.profile)
	}
	
	private func _fetchAndUpdate(profile: Profile) async {
		await __fetchUpdate {
			try await Olympia.aggregate(fiat: UserDefaults.defaultFiat, profile: profile)
		}
	}
	

	
	private func __fetchUpdate(_ fetch: () async throws -> Report) async {
		do {
			let report = try await fetch()
			let timestamp = Date.now
			let cached = CachedReport(report: report, timestamp: timestamp)
			UserDefaults.standard.saveCached(cached)
			reportState = .loaded(report)
			lastFetched = timestamp
		} catch {
			reportState = .failed(error)
		}
	}
	
	var hasRelevantData: Bool {
		if report != nil, let lastFetched, lastFetched.wasRecent {
			return true
		}
		return false
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

struct ReportView: SwiftUI.View {
	let report: Report
	var body: some View {
		Text("\(report.descriptionOrIngored(fiat: UserDefaults.defaultFiat))")
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
	var profileURL: URL? {
		guard let urlString = string(forKey: profileFilePathKey) else {
			return nil
		}
		return URL(string: urlString)
	}
	func setProfilePath(_ path: URL) {
		setValue(path.absoluteString, forKey: profileFilePathKey)
	}
	
	var lastFetched: Date? {
		guard case let timestamp = double(forKey: lastFetchedKey), timestamp > 0 else {
			return nil
		}
		return Date.init(timeIntervalSince1970: timestamp)
	}
	
	func setLastFetched(_ date: Date = .now) {
		setValue(date.timeIntervalSince1970, forKey: lastFetchedKey)
	}
	
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


let profileFilePathKey = "profileFilePathKey"
let lastFetchedKey = "lastFetchedKey"
let cachedReportKey = "cachedReportKey"
