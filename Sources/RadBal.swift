import Foundation
import BigInt

struct Profile: Decodable {
	
	/// Name of "Profile" / "wallet"
	let name: String
	
	/// All accounts associated with this profile/wallet.
	let accounts: [Account]
	
	struct Account: Decodable {
		
		/// HD Index
		let index: Int
		
		/// Display name / label of account
		let name: String?
		
		/// Radix Olympia bech32 encoded address
		let address: String
		
		let trades: [Trade]?
		
		struct Trade: Decodable {
			/// Radix Resource Identifier of the shitcoin bought
			let rri: String
			
			/// A hint, of the name of the project
			let name: String
			
			/// Number of altcoins bought, base 10, as a string
			let altcoinAmountString: String
			var altcoinAmount: BigInt { .init(altcoinAmountString, radix: 10)! }
			
			/// Number of XRDs sold, base 10, as a string
			let xrdAmountSpentString: String
			var xrdAmountSpent: BigInt { .init(xrdAmountSpentString, radix: 10)! }
			
			/// Date the trade took place
			let purchaseDate: Date
		}
	}
}

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
					
		
