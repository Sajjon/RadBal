//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-14.
//

import Backend

@main
struct CLI {
	public static func main() async throws {
		let fiat: Fiat = .sek
		let separator = "~~~ √  Radix Aggregated Balances √ ~~~"
		print("\n\n\n" + separator)
		if let legacy = try? await Olympia.aggregate(fiat: fiat, profile: ".profile.legacy.json", optional: true) {
			print("\nLEGACY:\n\(legacy.descriptionOrIngored(fiat: fiat))\n")
		}
		let babylonReady = try await Olympia.aggregate(fiat: fiat, profile: ".profile.json")
		print("BABYLON:\n\(babylonReady.descriptionOrIngored(fiat: fiat))")
		print("\n" + separator + "\n\n\n")
	}
}
