//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation
import BigDecimal

struct Profile: Decodable {
	
	/// Name of "Profile" / "wallet"
	let name: String
	
	/// All accounts associated with this profile/wallet.
	let accounts: [Account]
	
	struct Account: Decodable, Hashable, CustomStringConvertible {
		
		/// HD Index
		let index: Int
		
		/// Display name / label of account
		let name: String?
		
		/// Radix Olympia bech32 encoded address
		let address: String
		
		var shortAddress: String {
			String(address.suffix(8))
		}
		
		var nameOrIndex: String {
			name.map { "'\($0)'" } ?? "\(index)"
		}
		
		var description: String {
			[
				nameOrIndex,
				"...\(shortAddress)"
			].joined(separator: " | ")
		}
		
		let trades: [Trade]?
		
		struct Trade: Decodable, Hashable {
			/// Radix Resource Identifier of the shitcoin bought
			let rri: String
			
			/// A hint, of the name of the project
			let name: String
			
			/// Number of altcoins bought, base 10, as a string
			let altcoinAmountString: String
			var altcoinAmount: BigDecimal {
				BigDecimal(altcoinAmountString)
			}
			
			/// Number of XRDs sold, base 10, as a string
			let xrdAmountSpentString: String
			var xrdAmountSpent: BigDecimal {
				BigDecimal(xrdAmountSpentString)
			}
			
			var priceInXRD: BigDecimal {
				let price = xrdAmountSpent.divide(altcoinAmount, .decimal128)
				return price
			}
			
			/// Date the trade took place
			let purchaseDate: Date
		}
	}
}
