//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation

struct TokenBalance {
	let account: String
	let xrdLiquid: Number
	let xrdStaked: Number
	let altCoinsBalances: [TokenAmount]
	
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
			.reduce(0, +)

		self.xrdStaked = try portfolio
			.account_balances
			.staked_and_unstaking_balance
			.amount()
		
		self.altCoinsBalances = portfolio.account_balances.liquid_balances.filter { !$0.token_identifier.isXRD }
	}
}
