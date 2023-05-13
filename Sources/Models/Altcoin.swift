//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation

struct Altcoin: Hashable {
	let tokenInfo: TokenInfo
	let priceInXRD: Double
	var returnOnInvestment: Double? {
		guard let purchase else { return nil }
		return priceInXRD / purchase.priceInXRD
	}
	let purchase: Profile.Account.Trade?
}
