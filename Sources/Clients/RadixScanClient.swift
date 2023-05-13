//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation
import BigDecimal

struct Prices: Decodable, Equatable {
	let Ociswap: Dictionary<String, Double>
}

actor PricesCacheActor: GlobalActor {
	fileprivate private(set) var cached: Prices?
	private init() {}
	static let shared = PricesCacheActor()
	func cache(_ prices: Prices) {
		self.cached = prices
		
		print("\n\n\n\n\n\n🔮🔮🔮🔮🔮🔮🔮🔮🔮\n\nprices: \(prices)")
	}
	
}

extension Prices {
	var xrdInUSD: Double {
		self.Ociswap[xrd]!
	}
}

enum RadixScanClient {}
extension RadixScanClient {

	private static let baseURL = "https://www.radixscan.io/raw/tokenprices/"
	
	private static func _prices(of rris: [String]) async throws -> Prices {
		precondition(!rris.isEmpty)
		if let cached = await PricesCacheActor.shared.cached {
			return cached
		}
		
		let url = baseURL + rris.first! // yes
		let request = URLRequest(url: .init(string: url)!)
		let (data, response) = try await URLSession.shared.data(for: request)
		guard let httpURLResponse = response as? HTTPURLResponse else {
			throw FailedToFetchNotHTTPURLResponse()
		}
		guard httpURLResponse.statusCode == 200 else {
			throw FailedToFetchBadStatusCode(statusCode: httpURLResponse.statusCode)
		}
		let jsonDecoder = JSONDecoder()
		
		let prices = try jsonDecoder.decode(Prices.self, from: data)
		await PricesCacheActor.shared.cache(prices)
		
		return prices
	}
	
	static func prices(
		of rris: [String]
	) async throws -> [PriceInfo] {
		let prices = try await _prices(of: rris)
		return rris.compactMap { rri -> PriceInfo? in
			guard let value = prices.Ociswap[rri] else {
				return nil
			}
			return PriceInfo(
				rri: rri,
				inUSD: BigDecimal(value),
				inXRD: BigDecimal(value / prices.xrdInUSD)
			)
		}
		
	}
	
	static func price(of rri: String) async throws -> PriceInfo? {
		try await prices(of: [rri]).first(where: { $0.rri == rri })
	}
	
	static func info(of rri: String) async throws -> TokenInfo {
		if let cached = await TokenInfoCacheActor.shared.cache[rri] {
			return cached
		}
		struct TokenInfoRaw: Decodable {
			let result: TokenInfo
		}
		let url = "https://www.radixscan.io/raw/token/\(rri)"
		let request = URLRequest(url: .init(string: url)!)
		let (data, response) = try await URLSession.shared.data(for: request)
		guard let httpURLResponse = response as? HTTPURLResponse else {
			throw FailedToFetchNotHTTPURLResponse()
		}
		guard httpURLResponse.statusCode == 200 else {
			throw FailedToFetchBadStatusCode(statusCode: httpURLResponse.statusCode)
		}
		let jsonDecoder = JSONDecoder()
		let tokenInfoRaw = try jsonDecoder.decode(TokenInfoRaw.self, from: data)
		let tokenInfo = tokenInfoRaw.result
		await TokenInfoCacheActor.shared.cache(info: tokenInfo)
		return tokenInfo
	}
	
}

actor TokenInfoCacheActor: GlobalActor {
	fileprivate private(set) var cache: [TokenInfo.ID: TokenInfo] = [:]
	private init() {}
	static let shared = TokenInfoCacheActor()
	func cache(info: TokenInfo) {
		cache[info.id] = info
	}
	
	
}
