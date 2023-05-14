import Foundation
import BigDecimal

/// Held tokens for any account worth less than this threshold will not be displayed or
/// added to the aggregate worth of the profile. aka. "shitcoin filter".
let thresholdValueInUSD = BigDecimal(500)
let thresholdXRDAmount = BigDecimal(500)
let aggThresholdXRDAmount = BigDecimal(3000)

@main
public struct RadBal {
	
	static func aggregate(
		fiat: Fiat,
		profile profilePath: String,
		optional: Bool = false
	) async throws -> ProfileFetched {
		let url: URL = FileManager.default.homeDirectoryForCurrentUser.appending(path: profilePath)
		guard let profileData = try? Data(contentsOf: url) else {
			if !optional {
				print("Missing '\(profilePath)', create the file and place it in the root of the project.")
			}
			struct MissingFile: Error {}
			throw MissingFile()
		}
		let jsonDecoder = JSONDecoder()
		jsonDecoder.dateDecodingStrategy = .iso8601
		let profile = try jsonDecoder.decode(Profile.self, from: profileData)
		return try await Aggregator.of(profile: profile, fiat: fiat)
	}
	
	public static func main() async throws {
		let fiat: Fiat = .sek
		let separator = "~~~ √  Radix Aggregated Balances √ ~~~"
		print("\n\n\n" + separator)
		if let legacy = try? await aggregate(fiat: fiat, profile: ".profile.legacy.json", optional: true) {
			print("\nLEGACY:\n\(legacy.descriptionOrIngored(fiat: fiat))\n")
		}
		let babylonReady = try await aggregate(fiat: fiat, profile: ".profile.json")
		print("BABYLON:\n\(babylonReady.descriptionOrIngored(fiat: fiat))")
		print("\n" + separator + "\n\n\n")
	}
}
					
		
