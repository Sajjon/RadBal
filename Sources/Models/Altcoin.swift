//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation
import BigDecimal

struct AltcoinBalance: Hashable {
	let balance: BigDecimal
	let price: PriceInfo
	let tokenInfo: TokenInfo
	let purchase: Profile.Account.Trade?
}

extension AltcoinBalance {
	
	var worthInUSD: BigDecimal {
		balance * price.inUSD
	}
	
	var worthInXRD: BigDecimal {
		balance * price.inXRD
	}
	
	var returnOnInvestment: BigDecimal? {
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
