//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation
import BigInt

struct Aggregate {
	let profile: Profile
	let xrdLiquid: BigInt
	let xrdStaked: BigInt
	
	var summary: String {
		"""
		Profile: '\(profile.name)'
		XRD Grand Total: \(xrdLiquid + xrdStaked)
			available: \(xrdLiquid)
			staked: \(xrdStaked)
		#\(profile.accounts.count) accounts
		"""
	}
}
