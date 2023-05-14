//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation
import BigDecimal

struct TokenBalance {
	let account: String
	let xrdLiquid: BigDecimal
	let xrdStaked: BigDecimal
	let altCoinsBalances: [TokenAmount]
	
	init(
		account: String,
		portfolio: Portfolio
	) throws {
		self.account = account
		
		self.xrdLiquid = try portfolio
			.balances
			.liquidBalances
			.compactMap {
				guard $0.isXRD else { return nil }
				return try $0.amount()
			}
			.reduce(BigDecimal(0), +)

		self.xrdStaked = try portfolio
			.balances
			.stakedAndUnstakingBalance
			.amount()
		
		self.altCoinsBalances = portfolio.balances.liquidBalances.filter { !$0.isXRD }
	}
}
