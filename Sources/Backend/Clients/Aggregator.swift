//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation
import BigDecimal

enum Aggregator {}
extension Aggregator {
	
	
	static func detailedAccountInfo(_ account: Profile.Account) async throws -> Report.Account {
		let tokenBalances = try await RadixDLTGateway.getBalanceOfAccount(address: account.address)
		
		guard !tokenBalances.altCoinsBalances.isEmpty else {
			return Report.Account(
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
		
		let fetchedAccount = Report.Account(
			account: account,
			xrdLiquid: tokenBalances.xrdLiquid,
			xrdStaked: tokenBalances.xrdStaked,
			altcoinBalances: altcoinBalances.filter { $0.worthInUSD > thresholdValueInUSD }
		)
		return fetchedAccount
	}
	
	static func of(profile: Profile, fiat: Fiat) async throws -> Report {
		let accounts = try await profile.accounts.asyncMap { try await Self.detailedAccountInfo($0) }
		
		let usdValueInSelectedFiat = try await BigDecimal(FiatCurrencyConverter.priceInUSD(of: fiat))
		
		let xrdValueInUSD = try await Self.priceOfXRDinUSD()
		
		let xrdValueInSelectedFiat = usdValueInSelectedFiat * xrdValueInUSD
	
		return Report(
			profile: profile,
			accounts: accounts,
			usdValueInSelectedFiat: usdValueInSelectedFiat,
			xrdValueInUSD: xrdValueInUSD,
			xrdValueInSelectedFiat: xrdValueInSelectedFiat
		)
		
	}
	
	static func priceOfXRDinUSD() async throws -> BigDecimal {
		guard let price = try await RadixScanClient.price(of: xrd) else {
			throw FailedToGetPriceOfXRDInUSD()
		}
		return price.inUSD
	}
}

struct FailedToGetPriceOfXRDInUSD: Error {}

enum FiatCurrencyConverter {}
extension FiatCurrencyConverter {
	static func priceInUSD(of fiat: Fiat) async throws -> Double {
		let ticker = fiat.ticker
		let url = "https://open.er-api.com/v6/latest/\(ticker)"
		let request = URLRequest(url: .init(string: url)!)
		let (data, response) = try await URLSession.shared.data(for: request)
		guard let httpURLResponse = response as? HTTPURLResponse else {
			throw FailedToFetchNotHTTPURLResponse()
		}
		guard httpURLResponse.statusCode == 200 else {
			throw FailedToFetchBadStatusCode(statusCode: httpURLResponse.statusCode)
		}
		let jsonDecoder = JSONDecoder()
		struct Response: Decodable {
			let rates: Dictionary<String, Double>
		}
		let responseRaw = try jsonDecoder.decode(Response.self, from: data)
		let rates = responseRaw.rates
		guard
			rates.contains(where: { $0.key.uppercased() == ticker.uppercased() }),
			let rateInUSDPair = rates.first(where: { $0.key.uppercased() == Fiat.usd.ticker.uppercased() })
		else {
			struct NoRateFound: Error {}
			throw NoRateFound()
		}
		return 1.0 / rateInUSDPair.value
	}
}

extension Fiat {
	var ticker: String {
		switch self {
		case .sek: return "SEK"
		case .usd: return "USD"
		}
	}
}
