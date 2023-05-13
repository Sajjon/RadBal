//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation
import BigInt

struct TokenAmount: Decodable {
	let value: String
	func amount() throws -> BigInt {
		guard let whole = BigInt(value.dropLast(18), radix: 10) else {
			throw FailedToConvertFromAttos()
		}
		return whole
	}
	let token_identifier: TokenID
}

struct Portfolio: Decodable {
	let account_balances: Balances
	struct Balances: Decodable {
		let staked_and_unstaking_balance: TokenAmount
		let liquid_balances: [TokenAmount]
	}
}
