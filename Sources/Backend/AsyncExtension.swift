//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation

extension Sequence {
	func asyncMap<T>(
		_ transform: (Element) async throws -> T
	) async rethrows -> [T] {
		var values = [T]()

		for element in self {
			try await values.append(transform(element))
		}

		return values
	}
}
extension Sequence {
	func asyncCompactMap<T>(
		_ transform: (Element) async throws -> T?
	) async rethrows -> [T] {
		var values = [T]()

		for element in self {
			if let v = try await transform(element) {
				values.append(v)
			}
		}

		return values
	}
}
