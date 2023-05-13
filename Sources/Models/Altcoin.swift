//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation

struct AltcoinBalance: Hashable {
	let balance: Number
	let price: PriceInfo
	let tokenInfo: TokenInfo
	let purchase: Profile.Account.Trade?
}

extension AltcoinBalance {
	
	var worthInUSD: Number {
		balance * price.inUSD
	}
	
	var worthInXRD: Number {
		balance * price.inXRD
	}
	
	var returnOnInvestment: Number? {
		guard let purchase else { return nil }
		return worthInUSD / purchase.priceInXRD
	}
	
	var detailed: String {
		let exclRoi = "\(tokenInfo.symbol): \(balance) => XRD: \(worthInUSD)"
		guard let roi = returnOnInvestment else {
			return exclRoi
		}
		
		return exclRoi + " | ROI: \(roi)"
	}
}
