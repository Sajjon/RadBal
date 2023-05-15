//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation
import BigDecimal

public struct PriceInfo: Hashable, Codable {
	public let rri: String
	public let inUSD: BigDecimal
	public let inXRD: BigDecimal
}
