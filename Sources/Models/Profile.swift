//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation
import BigInt

struct Profile: Decodable {
	
	/// Name of "Profile" / "wallet"
	let name: String
	
	/// All accounts associated with this profile/wallet.
	let accounts: [Account]
	
	struct Account: Decodable, Hashable {
		
		/// HD Index
		let index: Int
		
		/// Display name / label of account
		let name: String?
		
		/// Radix Olympia bech32 encoded address
		let address: String
		
		let trades: [Trade]?
		
		struct Trade: Decodable, Hashable {
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
			
			var priceInXRD: Double {
				Double(xrdAmountSpent) / Double(altcoinAmount)
			}
			
			/// Date the trade took place
			let purchaseDate: Date
		}
	}
}
