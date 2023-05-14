//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation

struct PricedToken: Comparable, Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(token.rri)
	}
	static func < (lhs: PricedToken, rhs: PricedToken) -> Bool {
		lhs.usdValue < rhs.usdValue
	}
	
	let token: TokenInfo
	let usdValue: Float
	
}
