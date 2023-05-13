//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation


enum Aggregator {}
extension Aggregator {
	
	
	static func detailedAccountInfo(_ account: Profile.Account) async throws -> ProfileFetched.Account {
		let tokenBalances = try await RadixDLTGateway.getBalanceOfAccount(address: account.address)
		
		guard !tokenBalances.altCoinsBalances.isEmpty else {
			return ProfileFetched.Account(
				account: account,
				xrdLiquid: tokenBalances.xrdLiquid,
				xrdStaked: tokenBalances.xrdStaked,
				altcoinBalances: []
			)
		}
		
		let altcoinBalances: [AltcoinBalance] = try await tokenBalances
			.altCoinsBalances
			.asyncCompactMap { altcoinBalanceSimple -> AltcoinBalance? in
				let rri = altcoinBalanceSimple.rri
				guard let price = try await RadixScanClient.price(of: rri) else {
					return nil
				}
				let tokenInfo = try await RadixScanClient.info(of: rri)
				
				return try AltcoinBalance(
					balance: altcoinBalanceSimple.amount(),
					price: price,
					tokenInfo: tokenInfo,
					purchase: account.trades?.first(where: { $0.rri == rri })
				)
			}
		
		let fetchedAccount = ProfileFetched.Account(
			account: account,
			xrdLiquid: tokenBalances.xrdLiquid,
			xrdStaked: tokenBalances.xrdStaked,
			altcoinBalances: altcoinBalances.filter { $0.worthInXRD >= thresholdValueInUSD }
		)
		print("done: \(fetchedAccount)")
		return fetchedAccount
	}
	
	static func of(profile: Profile) async throws -> ProfileFetched {
		let accounts = try await profile.accounts.asyncMap { try await Self.detailedAccountInfo($0) }
		
		return ProfileFetched(
			name: profile.name,
			accounts: accounts
		)
		
	}
	
}
