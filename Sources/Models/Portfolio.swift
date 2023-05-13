//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation

struct TokenAmount: Decodable {
	let value: String
	func amount() throws -> Number {
		guard let whole = Number(value.dropLast(18)) else {
			throw FailedToConvertFromAttos()
		}
		return whole
	}
	let token_identifier: TokenID
	var rri: String {
		token_identifier.rri
	}
}

struct Portfolio: Decodable {
	let account_balances: Balances
	struct Balances: Decodable {
		let staked_and_unstaking_balance: TokenAmount
		let liquid_balances: [TokenAmount]
	}
}
