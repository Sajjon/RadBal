//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation
import BigInt

enum Aggregator {}
extension Aggregator {
	
	static func of(profile: Profile) async throws -> Aggregate {
		
		try await withThrowingTaskGroup(of: TokenBalance.self, returning: Aggregate.self) { group in
			for account in profile.accounts.map(\.address) {
				_ = group.addTaskUnlessCancelled {
					try await RadixDLTGateway.getBalanceOfAccount(address: account)
				}
			}
			let (liquid, staked) = try await group.reduce((BigInt.zero, BigInt.zero), { ($0.0 + $1.xrdLiquid, $0.1 + $1.xrdStaked) })
			
			return Aggregate(
				profile: profile,
				xrdLiquid: liquid,
				xrdStaked: staked
			)
		}
	}
	
}
