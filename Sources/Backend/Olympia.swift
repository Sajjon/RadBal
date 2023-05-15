import Foundation
import BigDecimal

/// Held tokens for any account worth less than this threshold will not be displayed or
/// added to the aggregate worth of the profile. aka. "shitcoin filter".
let thresholdValueInUSD = BigDecimal(500)
let thresholdXRDAmount = BigDecimal(500)
let aggThresholdXRDAmount = BigDecimal(3000)

public enum Olympia {}
extension Olympia {
	
	@available(iOS, unavailable, message: "No home dir in iOS")
	@available(macOS 13, *)
	public static func aggregate(
		fiat: Fiat,
		profilePath: String = ".profile.json",
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

		guard url.startAccessingSecurityScopedResource() else { // Notice this line right here
			print("Failed to startAccessingSecurityScopedResource")
			struct UnableToStartAccessingSecurityScopedResource: Error {}
			throw UnableToStartAccessingSecurityScopedResource()
		}
		
		let profileData: Data
		do {
			profileData = try Data(contentsOf: url)
		} catch {
			print("Unable to read file at path: \(url), error: \(String(describing: error))")
			throw error
		}
		 
		let jsonDecoder = JSONDecoder()
		jsonDecoder.dateDecodingStrategy = .iso8601
		let profile = try jsonDecoder.decode(Profile.self, from: profileData)
		return try await aggregate(fiat: fiat, profile: profile)
	}
	
	public static func aggregate(
		fiat: Fiat,
		profile: Profile
	) async throws -> Report {
		try await Aggregator.of(profile: profile, fiat: fiat)
	}
}
					
		
