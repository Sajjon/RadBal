//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation

private let xrd = "xrd_rr1qy5wfsfh"

struct TokenID: Decodable {
	let rri: String
	var isXRD: Bool {
		rri == xrd
	}
}
