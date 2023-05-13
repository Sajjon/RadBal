//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation
import BigDecimal


struct PriceInfo: Hashable {
	let rri: String
	let inUSD: BigDecimal
	let inXRD: BigDecimal
}
