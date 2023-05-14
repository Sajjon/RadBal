import Foundation
import BigDecimal

/// Held tokens for any account worth less than this threshold will not be displayed or
/// added to the aggregate worth of the profile. aka. "shitcoin filter".
let thresholdValueInUSD = BigDecimal(500)
let thresholdXRDAmount = BigDecimal(1000)

@main
public struct RadBal {
	
	static func aggregate(
		profile profilePath: String,
		optional: Bool = false
	) async throws -> ProfileFetched {
		let url: URL = FileManager.default.homeDirectoryForCurrentUser.appending(path: profilePath)
		let profileData = try Data(contentsOf: url)
//		guard let profileData = FileManager.default.contents(atPath: profilePath) else {
//			if !optional {
//				print("Missing '\(profilePath)', create the file and place it in the root of the project.")
//			}
//			struct MissingFile: Error {}
//			throw MissingFile()
//		}
		let jsonDecoder = JSONDecoder()
		jsonDecoder.dateDecodingStrategy = .iso8601
		let profile = try jsonDecoder.decode(Profile.self, from: profileData)
		return try await Aggregator.of(profile: profile)
	}
	
	public static func main() async throws {
		let separator = "~~~ √  Radix Aggregated Balances √ ~~~"
//		print("\n\n\n" + separator)
//		if let legacy = try? await aggregate(profile: ".profile.legacy.json", optional: true) {
//			print("\nLEGACY:\n\(legacy)\n")
//		}
		let babylonReady = try await aggregate(profile: ".profile.json")
		print("BABYLON:\n\(babylonReady)")
		print(separator + "\n\n\n")
	}
}
					
		
