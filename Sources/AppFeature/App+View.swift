//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-14.
//

import Foundation
import SwiftUI

public struct AppView: SwiftUI.View {
	public init() {}
	public var body: some SwiftUI.View {
		VStack {
			Image(systemName: "globe")
				.imageScale(.large)
				.foregroundColor(.accentColor)
			Text("Hello, world!")
		}
		.padding()
	}
}
