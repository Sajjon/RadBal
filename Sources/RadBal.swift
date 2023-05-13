import Foundation
import BigInt

@main
public struct RadBal {
	
	static func aggregate(
		profile profilePath: String,
		optional: Bool = false
	) async throws -> Aggregate {
		guard let profileData = FileManager.default.contents(atPath: profilePath) else {
			if !optional {
				print("Missing '\(profilePath)', create the file and place it in the root of the project.")
			}
			struct MissingFile: Error {}
			throw MissingFile()
		}
		var jsonDecoder = JSONDecoder()
		jsonDecoder.dateDecodingStrategy = .iso8601
		let profile = try jsonDecoder.decode(Profile.self, from: profileData)
		return try await Aggregator.of(profile: profile)
	}
	
	public static func main() async throws {
		let separator = "~~~ √  Radix Aggregated Balances √ ~~~"
		print("\n\n\n" + separator)
		if let legacy = try? await aggregate(profile: ".profile.legacy.json", optional: true) {
			print("\nLEGACY:\n\(legacy.summary)\n")
		}
		let babylonReady = try await aggregate(profile: ".profile.json")
		print("BABYLON:\n\(babylonReady.summary)")
		print(separator + "\n\n\n")
	}
}
					
		
