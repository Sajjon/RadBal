import Foundation
import BigInt

@main
public struct RadBal {
	
	static func aggregate(
		list accountListFilePath: String
	) async throws -> Aggregate {
		guard let accountlistData = FileManager.default.contents(atPath: accountListFilePath) else {
			print("Missing '\(accountListFilePath)', create the file and place it in the root of the project, being a JSON array with list of addresses.")
			struct MissingFile: Error {}
			throw MissingFile()
		}
		let accountList = try JSONDecoder().decode(Set<String>.self, from: accountlistData)
		return try await Aggregator.of(accounts: accountList)
	}
	
	public static func main() async throws {
		let separator = "~~~ √  Radix Aggregated Balances √ ~~~"
		print("\n\n\n" + separator)
		let legacy = try await aggregate(list: ".accounts_legacy.json")
		print("\nLEGACY:\n\(legacy.summary)")
		let babylonReady = try await aggregate(list: ".accounts.json")
		print("\nBABYLON:\n\(babylonReady.summary)")
		print(separator + "\n\n\n")
	}
}
					
		
