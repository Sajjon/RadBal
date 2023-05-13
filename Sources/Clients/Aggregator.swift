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
	
	static func detailedAccountInfo(_ account: Profile.Account) async throws -> ProfileFetched.Account {
		let xrdBalance = try await RadixDLTGateway.getBalanceOfAccount(address: account.address)
		return .init(xrdBalance: xrdBalance, account: account, altcoins: [])
	}
	
	static func of(profile: Profile) async throws -> ProfileFetched {
		
		try await withThrowingTaskGroup(of: ProfileFetched.Account.self, returning: ProfileFetched.self) { group in
			var accountsFetched: Set<ProfileFetched.Account> = []
			for account in profile.accounts {
				_ = group.addTaskUnlessCancelled {
					try await Self.detailedAccountInfo(account)
				}
			}
			for try await fetchedAccount in group {
				accountsFetched.insert(fetchedAccount)
			}
	
			return ProfileFetched(
				name: profile.name,
				accounts: Array(accountsFetched)
			)
		}
	}
	
}
