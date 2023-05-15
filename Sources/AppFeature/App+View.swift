//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-14.
//

import Foundation
import SwiftUI
import Backend

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
}

public struct AppView: SwiftUI.View {
	@State var reportState: ReportLoadState = .new
	public init() {}
	public var body: some SwiftUI.View {
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
				ReportView(report: report)
			case let .loading(fileURL):
				VStack {
					Text("Loading...")
					ProgressView()
				}
				.task {
					do {
						reportState = try await .loaded(Olympia.aggregate(
							fiat: UserDefaults.defaultFiat,
							profileURL: fileURL
						))
					} catch {
						reportState = .failed(error)
					}
				}
			case let .failed(error):
				Text("Failed to load: \(String(describing: error))")
			}
		}
	
		.padding()
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
