//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation
import BigInt

struct ProfileFetched {
	struct Account: Hashable {
		
		let account: Profile.Account
		let xrdLiquid: BigInt
		let xrdStaked: BigInt
		let altcoins: [Altcoin]
		
		init(
			xrdBalance: TokenBalance,
			account: Profile.Account,
			altcoins: [Altcoin] = []
		) {
			precondition(xrdBalance.account == account.address)
			self.account = account
			self.xrdLiquid = xrdBalance.xrdLiquid
			self.xrdStaked = xrdBalance.xrdStaked
			self.altcoins = altcoins
		}
	}
	
	/// Name of "Profile" / "wallet"
	let name: String
	
	/// All accounts associated with this profile/wallet.
	let accounts: [Account]
	
	var xrdLiquid: BigInt {
		accounts.reduce(BigInt.zero) { $0 + $1.xrdLiquid }
	}
	var xrdStaked: BigInt {
		accounts.reduce(BigInt.zero) { $0 + $1.xrdStaked }
	}
	
	var summary: String {
		"""
		Profile: '\(name)'
		XRD Grand Total: \(xrdLiquid + xrdStaked)
			available: \(xrdLiquid)
			staked: \(xrdStaked)
		#\(accounts.count) accounts
		"""
	}
}


