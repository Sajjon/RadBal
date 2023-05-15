//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation
import BigDecimal

public struct Profile: Codable {
	
	/// Name of "Profile" / "wallet"
	public let name: String
	
	/// All accounts associated with this profile/wallet.
	public let accounts: [Account]
	
	public struct Account: Codable, Hashable, CustomStringConvertible {
		
		/// HD Index
		public let index: Int
		
		/// Display name / label of account
		public let name: String?
		
		/// Radix Olympia bech32 encoded address
		public let address: String
		
		public let trades: [Trade]?
	}
}

public struct Trade: Codable, Hashable {
	/// Radix Resource Identifier of the shitcoin bought
	public let rri: String
	
	/// A hint, of the name of the project
	public let name: String
	
	/// Date the trade took place
	public let purchaseDate: Date
	
	/// Number of altcoins bought, base 10, as a string
	let altcoinAmountString: String
	
	/// Number of XRDs sold, base 10, as a string
	let xrdAmountSpentString: String
	
}
extension Trade {
	
	public var priceInXRD: BigDecimal {
		let price = xrdAmountSpent.divide(altcoinAmount, .decimal128)
		return price
	}
	
	public var xrdAmountSpent: BigDecimal {
		BigDecimal(xrdAmountSpentString)
	}
	
	public var altcoinAmount: BigDecimal {
		BigDecimal(altcoinAmountString)
	}
}

extension Profile.Account {
	public var shortAddress: String {
		String(address.suffix(6))
	}
	
	public var nameOrIndex: String {
		name.map { "'\($0)'" } ?? "\(index)"
	}
	
	public var description: String {
		[
			nameOrIndex,
			"...\(shortAddress)"
		].joined(separator: " | ")
	}
	
}
