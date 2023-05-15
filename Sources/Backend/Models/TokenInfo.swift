//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation

public struct TokenInfo: Codable, Hashable, Identifiable {
	public typealias ID = String
	public var id: ID { rri }
	public let tokenInfoURL: String // "https://caviarnine.com/",
	public let symbol: String
	public let isSupplyMutable: Bool
	public let granularity: String
	public let name: String//"Floop",
	public let rri: String // "floop_rr1q0p0hzap6ckxqdk6khesyft62w34e0vdd06msn9snhfqknl370",
	public let description: String // "Flippity floppity floop",
	public let currentSupply: String // "1000000000000000000000",
	public let iconURL: String // "https://caviarnine.com/c9_icon_trans_32x32.png"
}
