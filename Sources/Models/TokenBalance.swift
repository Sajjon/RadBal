//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation
import BigInt

struct TokenBalance {
	let account: String
	let xrdLiquid: BigInt
	let xrdStaked: BigInt
	
	init(
		account: String,
		portfolio: Portfolio
	) throws {
		self.account = account
		
		self.xrdLiquid = try portfolio
			.account_balances
			.liquid_balances
			.compactMap {
				guard $0.token_identifier.isXRD else { return nil }
				return try $0.amount()
			}
			.reduce(BigInt.zero, +)

		self.xrdStaked = try portfolio
			.account_balances
			.staked_and_unstaking_balance
			.amount()
	}
}
