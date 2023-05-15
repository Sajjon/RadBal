import Foundation
import BigDecimal

/// Held tokens for any account worth less than this threshold will not be displayed or
/// added to the aggregate worth of the profile. aka. "shitcoin filter".
let thresholdValueInUSD = BigDecimal(500)
let thresholdXRDAmount = BigDecimal(500)
let aggThresholdXRDAmount = BigDecimal(3000)

public enum Olympia {}
extension Olympia {
	
	public static func aggregate(
		fiat: Fiat,
		profile profilePath: String = ".profile.json",
		optional: Bool = false
	) async throws -> Report {
		let url: URL = FileManager.default.homeDirectoryForCurrentUser.appending(path: profilePath)
		return try await aggregate(fiat: fiat, profileURL: url, optional: optional)
	}
	
	public static func aggregate(
		fiat: Fiat,
		profileURL url: URL,
		optional: Bool = false
	) async throws -> Report {
		guard let profileData = try? Data(contentsOf: url) else {
			if !optional {
				print("Missing '\(url)', create the file and place it in the root of the project.")
			}
			struct MissingFile: Error {}
			throw MissingFile()
		}
		let jsonDecoder = JSONDecoder()
		jsonDecoder.dateDecodingStrategy = .iso8601
		let profile = try jsonDecoder.decode(Profile.self, from: profileData)
		return try await Aggregator.of(profile: profile, fiat: fiat)
	}
	
}
					
		
