//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation

enum RadixScanClient {}
extension RadixScanClient {
	private static let baseURL = "https://www.radixscan.io/raw/tokenprices/"
	
	static func prices(
		of rris: [String]
	) async throws -> [PriceInfo] {
		precondition(!rris.isEmpty)
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
		struct Prices: Decodable {
			let Ociswap: Dictionary<String, Float>
		}
		let prices = try jsonDecoder.decode(Prices.self, from: data)
		return rris.compactMap { rri in
			guard let value = prices.Ociswap[rri] else {
				return nil
			}
			return PriceInfo(rri: rri, usdValue: value)
		}
		
	}
	
	static func info(of rri: String) async throws -> TokenInfo {
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
		return tokenInfoRaw.result
	}
	
}
