//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation
import BigDecimal

struct AltcoinBalance: Hashable {
	let balance: BigDecimal
	let price: PriceInfo
	let tokenInfo: TokenInfo
	let purchase: Profile.Account.Trade?
}

extension AltcoinBalance {
	
	var worthInUSD: BigDecimal {
		balance * price.inUSD
	}
	
	var worthInXRD: BigDecimal {
		balance * price.inXRD
	}
	
	var returnOnInvestment: BigDecimal? {
		guard let purchase else { return nil }
		let roi = price.inXRD.divide(purchase.priceInXRD, .decimal128)
		return roi
	}
	
	var detailed: String {
		detail(showAltcoinAmount: false, showWorthInUSD: false)
	}
	
	func detail(showAltcoinAmount: Bool, showWorthInUSD: Bool) -> String {
		let amount: String? = showAltcoinAmount ? balance.amountOfAltcoinFormat : nil
		let worthInUSD: String? = showWorthInUSD ? worthInUSD.valueInDefaultFiatFormat : nil
		let roi: String? = returnOnInvestment.map { "| ROI: \($0.roiFormat)" }
		return Array<String?>([
			tokenInfo.symbol.uppercased(),
			amount,
			worthInXRD.amountOfXRDFormat,
			worthInUSD,
			roi
		]).compactMap({ $0 }).joined(separator: " ")
	}
}

extension BigDecimal {
	var amountOfXRDFormat: String {
		format(style: .amountOfXRD)
	}
	var valueInDefaultFiatFormat: String {
		format(style: .valueInDefaultFiat)
	}
	var valueInXRDFormat: String {
		format(style: .valueInXRD)
	}
	var amountOfAltcoinFormat: String {
		format(style: .amountOfAltcoin)
	}
	var roiFormat: String {
		if self > BigDecimal.ONE {
			let diff =  self - BigDecimal.ONE
			return "+\(diff.format(style: .percentage))"
		} else if self < BigDecimal.ONE {
			let diff = BigDecimal.ONE - self
			return "-\(diff.format(style: .percentage))"
		} else {
			return format(style: .percentage)
		}
	}
	
	enum Style {
		case amountOfXRD
		case valueInXRD
		case valueInFiat(Fiat)
		static let valueInDefaultFiat: Self = .valueInFiat(.default)
		case amountOfAltcoin
		case percentage
		var prefix: String? {
			switch self {
			case .amountOfAltcoin: return "∀"
			case .amountOfXRD, .valueInXRD: return "√"
			case .percentage: return ""
			case let .valueInFiat(fiat):
				return fiat.prefix
			}
		}
		var suffix: String? {
			switch self {
			case .amountOfAltcoin: return nil
			case .amountOfXRD: return nil
			case .percentage: return "%"
			case .valueInXRD: return nil
			case let .valueInFiat(fiat):
				return fiat.suffix
			}
		}
	}
	func format(style: Style) -> String {
		let rounded = round(style: style)
		let stringified = rounded.asString(.PLAIN)
		return [style.prefix, stringified, style.suffix].compactMap { $0 }.joined()
	}
	
	private func round(style: Style) -> Self {
		switch style {
		case .percentage:
			return (BigDecimal(100)*self).round(.init(.HALF_DOWN, 2))
		case .amountOfAltcoin:
			return round(.init(.HALF_DOWN, 6))
		case .valueInXRD, .amountOfXRD:
			return round(.init(.HALF_EVEN, 2)) // or rather `0`?
		case .valueInFiat:
			return round(.init(.UP, 0)) // or rather `0`?
		}
	}
}

enum Fiat {
	case usd
	case sek
	static let `default`: Self = .usd
	var prefix: String? {
		switch self {
		case .usd: return "$"
		case .sek: return nil
		}
	}
	var suffix: String? {
		switch self {
		case .usd: return nil
		case .sek: return ":-"
		}
	}
}
