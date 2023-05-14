//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation

struct TokenInfo: Decodable, Hashable, Identifiable {
	typealias ID = String
	var id: ID { rri }
	let tokenInfoURL: String // "https://caviarnine.com/",
	let symbol: String
	let isSupplyMutable: Bool
	let granularity: String
	let name: String//"Floop",
	let rri: String // "floop_rr1q0p0hzap6ckxqdk6khesyft62w34e0vdd06msn9snhfqknl370",
	let description: String // "Flippity floppity floop",
	let currentSupply: String // "1000000000000000000000",
	let iconURL: String // "https://caviarnine.com/c9_icon_trans_32x32.png"
}
