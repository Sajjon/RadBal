//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation
import BigDecimal

extension BigDecimal: Codable {
	public func encode(to encoder: Encoder) throws {
		var singleValueContainer = encoder.singleValueContainer()
		try singleValueContainer.encode(self.asString(.PLAIN))
	}
	public init(from decoder: Decoder) throws {
		let singleValuecontainer = try decoder.singleValueContainer()
		let string = try singleValuecontainer.decode(String.self)
		self.init(string)
	}
}

public struct AltcoinBalance: Hashable, Codable {
	public let balance: BigDecimal
	public let price: PriceInfo
	public let tokenInfo: TokenInfo
	public let purchase: Trade?
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
	
	
	func detail(
		fiat: Fiat,
		showAltcoinAmount: Bool = true,
		showWorthInUSD: Bool = true
	) -> String {
		let amount: String? = { () -> String? in
			guard showAltcoinAmount else { return nil }
			guard let purchase, case let diff = (purchase.altcoinAmount - balance).abs, diff > 10 else { return balance.amountOfAltcoinFormat }
			return balance.amountOfAltcoinFormat + " (bought: \(purchase.altcoinAmount.amountOfAltcoinFormat))"
		}()
		
		let worthInUSD: String? = showWorthInUSD ? worthInUSD.format(style: .valueInFiat(fiat)) : nil
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
	public var amountOfXRDFormat: String {
		format(style: .amountOfXRD)
	}

	public var valueInXRDFormat: String {
		format(style: .valueInXRD)
	}
	public var amountOfAltcoinFormat: String {
		format(style: .amountOfAltcoin)
	}
	public var roiFormat: String {
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
	
	public enum Style {
		case amountOfXRD
		case valueInXRD
		case valueInFiat(Fiat)
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
	public func format(style: Style) -> String {
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
			return round(.init(.HALF_EVEN, 2))
		case .valueInFiat:
			return round(.init(.HALF_EVEN, 3))
		}
	}
}

public enum Fiat {
	case usd
	case sek
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
