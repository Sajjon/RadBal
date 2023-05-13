//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation

struct FailedToFetchNotHTTPURLResponse: Swift.Error {}
struct FailedToFetchBadStatusCode: Swift.Error {
	let statusCode: Int
}
struct FailedToConvertFromAttos: Swift.Error {}


enum RadixDLTGateway {}
extension RadixDLTGateway {
	static func getBalanceOfAccount(
		address: String
	) async throws -> TokenBalance {
		var request = URLRequest(url: .init(string: "https://mainnet-gateway.radixdlt.com/account/balances")!)
		let jsonEncoder = JSONEncoder()
		struct Body: Encodable {
			let account_identifier: Account
			let network_identifier: Network
			struct Account: Encodable {
				let address: String
			}
			struct Network: Encodable {
				let network: String
				static let `default` = Self.init(network: "mainnet")
			}
			init(accountAddress: String) {
				self.account_identifier = .init(address: accountAddress)
				self.network_identifier = .default
			}
		}
		let body = Body(accountAddress: address)
		let bodyData = try jsonEncoder.encode(body)
		request.httpBody = bodyData
		request.httpMethod = "POST"
		request.allHTTPHeaderFields = [
			"Content-Type": "application/json"
		]
		let (data, response) = try await URLSession.shared.data(for: request)
		guard let httpURLResponse = response as? HTTPURLResponse else {
			throw FailedToFetchNotHTTPURLResponse()
		}
		guard httpURLResponse.statusCode == 200 else {
			throw FailedToFetchBadStatusCode(statusCode: httpURLResponse.statusCode)
		}
		let jsonDecoder = JSONDecoder()
		let portfolio = try jsonDecoder.decode(Portfolio.self, from: data)
		return try TokenBalance(account: address, portfolio: portfolio)
	}
}
