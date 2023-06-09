//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-14.
//

import Backend

@available(iOS, unavailable, message: "No home dir in iOS")
@available(macOS 13, *)
@main
struct CLI {
	
	@available(iOS, unavailable, message: "No home dir in iOS")
	@available(macOS 13, *)
	public static func main() async throws {
		let fiat: Fiat = .sek
		let separator = "~~~ √  Radix Aggregated Balances √ ~~~"
		print("\n\n\n" + separator)
		if let legacy = try? await Olympia.aggregate(fiat: fiat, profilePath: ".profile.legacy.json", optional: true) {
			print("\nLEGACY:\n\(legacy.descriptionOrIgnored(fiat: fiat))\n")
		}
		let babylonReady = try await Olympia.aggregate(fiat: fiat, profilePath: ".profile.json")
		print("BABYLON:\n\(babylonReady.descriptionOrIgnored(fiat: fiat))")
		print("\n" + separator + "\n\n\n")
	}
}
