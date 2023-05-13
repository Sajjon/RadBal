//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation

struct ProfileFetched: CustomStringConvertible {
	struct Account: Hashable {
		
		let account: Profile.Account
		let xrdLiquid: Number
		let xrdStaked: Number
		let altcoinBalances: [AltcoinBalance]

		init(
			account: Profile.Account,
			xrdLiquid: Number,
			xrdStaked: Number,
			altcoinBalances: [AltcoinBalance]
		) {
			precondition(altcoinBalances.allSatisfy({ $0.worthInUSD >= thresholdValueInUSD }))
			self.account = account
			self.xrdLiquid = xrdLiquid
			self.xrdStaked = xrdStaked
			self.altcoinBalances = altcoinBalances
		}
		
		var detailed: String {
			"Account: \(account):\n\(altcoinBalances.map(\.detailed).joined(separator: "\n"))"
		}
	}
	
	/// Name of "Profile" / "wallet"
	let name: String
	
	/// All accounts associated with this profile/wallet.
	let accounts: [Account]
	
	var xrdLiquid: Number {
		accounts.reduce(0) { $0 + $1.xrdLiquid }
	}
	var xrdStaked: Number {
		accounts.reduce(0) { $0 + $1.xrdStaked }
	}
	
	var detailed: String {
		accounts
			.map(\.detailed)
			.joined(separator: "\n")
	}
	
	var description: String {
		"""
		Profile: '\(name)'
		XRD Grand Total: \(xrdLiquid + xrdStaked)
			available: \(xrdLiquid)
			staked: \(xrdStaked)
		#\(accounts.count) accounts
		Detailed: \(detailed)
		"""
	}
}


