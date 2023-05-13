//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation
import BigInt

struct Aggregate {
	let accounts: Set<String>
	let xrdLiquid: BigInt
	let xrdStaked: BigInt
	
	var summary: String {
		"""
		XRD Grand Total: \(xrdLiquid + xrdStaked)
			available: \(xrdLiquid)
			staked: \(xrdStaked)
		#\(accounts.count) accounts
		"""
	}
}
