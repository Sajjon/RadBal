//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation
import BigDecimal

struct TokenAmount: Decodable {
	private let valueString: String
	private let tokenID: TokenID
}

extension TokenAmount {
	var rri: String {
		tokenID.rri
	}
	var isXRD: Bool {
		tokenID.isXRD
	}
	
	enum CodingKeys: String, CodingKey {
		case valueString = "value"
		case tokenID = "token_identifier"
	}
	
	func amount() throws -> BigDecimal {
//		let intermediary = value.dropLast(18)
		let value_ = BigDecimal(valueString)
		let attos = BigDecimal("1e18")
		let amount = value_ / attos
//		guard let whole = Number(intermediary) else {
//			print("❌\nvalue: '\(value)'\nintermediary: '\(intermediary)'")
//			throw FailedToConvertFromAttos()
//		}
		if valueString == "199999980000000000" {
			print("🔮\nrri:\(self.rri),value: '\(valueString)'\nattos: '\(attos)'\namount: '\(amount)'")
		}
		return amount
	}
}

struct Portfolio: Decodable {
	let balances: Balances
	struct Balances: Decodable {
		let stakedAndUnstakingBalance: TokenAmount
		let liquidBalances: [TokenAmount]
		enum CodingKeys: String, CodingKey {
			case stakedAndUnstakingBalance = "staked_and_unstaking_balance"
			case liquidBalances = "liquid_balances"
		}
	}
	enum CodingKeys: String, CodingKey {
		case balances = "account_balances"
	}
}
