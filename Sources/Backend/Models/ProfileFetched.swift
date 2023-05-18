//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation
import BigDecimal

public struct Report: Codable, Hashable {
	
	public let profile: Profile
	public var name: String {
		profile.name
	}
	
	/// All accounts associated with this profile/wallet.
	public let accounts: [Account]
	
	public let usdValueInSelectedFiat: BigDecimal
	public let xrdValueInUSD: BigDecimal
	public let xrdValueInSelectedFiat: BigDecimal
	
	public init(
		profile: Profile,
		accounts: [Account],
		usdValueInSelectedFiat: BigDecimal,
		xrdValueInUSD: BigDecimal,
		xrdValueInSelectedFiat: BigDecimal
	) {
		self.profile = profile
		self.accounts = accounts
		self.xrdValueInSelectedFiat = xrdValueInSelectedFiat
		self.xrdValueInUSD = xrdValueInUSD
		self.usdValueInSelectedFiat = usdValueInSelectedFiat
	}
}

extension Report {
	public struct Account: Hashable, Codable {
		
		public let account: Profile.Account
		public let xrdLiquid: BigDecimal
		public let xrdStaked: BigDecimal
		public let altcoinBalances: [AltcoinBalance]
		
		init(
			account: Profile.Account,
			xrdLiquid: BigDecimal,
			xrdStaked: BigDecimal,
			altcoinBalances: [AltcoinBalance]
		) {
			self.account = account
			self.xrdLiquid = xrdLiquid
			self.xrdStaked = xrdStaked
			self.altcoinBalances = altcoinBalances
		}
	}
}

extension Report.Account {
	
	public var hasAltcoinValueAboveThreshold: Bool {
		!altcoinBalances.isEmpty
	}
	
	public var xrdValueOfAllAltCoins: BigDecimal {
		altcoinBalances.map(\.worthInXRD).reduce(BigDecimal.ZERO, +)
	}

	public func details(fiat: Fiat) -> String {
		"\(account):\n\(altcoinBalances.map({ $0.detail(fiat: fiat) }).map{ $0.indent(level: 3) }.joined(separator: "\n"))"
	}

}

extension Report {
	public var xrdLiquid: BigDecimal {
		accounts.reduce(BigDecimal(0)) { $0 + $1.xrdLiquid }
	}
	public var xrdStaked: BigDecimal {
		accounts.reduce(BigDecimal(0)) { $0 + $1.xrdStaked }
	}
	
	private func condAgg(_ keyPath: KeyPath<Self, BigDecimal>) -> BigDecimal? {
		let value = self[keyPath: keyPath]
		guard value > aggThresholdXRDAmount else {
			return nil
		}
		return value
	}
	public var aggXRDAvailable: BigDecimal? {
		condAgg(\.xrdLiquid)
	}
	public var aggXRDStaked: BigDecimal? {
		condAgg(\.xrdStaked)
	}
	public var aggGrandTotal: BigDecimal {
		xrdLiquid + xrdStaked + xrdValueOfAllAltcoins
	}
	public var xrdValueOfAllAltcoins: BigDecimal {
		relevantAccounts.map(\.xrdValueOfAllAltCoins).reduce(BigDecimal.ZERO, +)
	}
	
	private func format(xrdAmount: BigDecimal, label: String) -> String {
		return "\(label): \(xrdAmount.amountOfXRDFormat)"
	}
	
	private func condAggXRDAmountFormatted(_ keyPath: KeyPath<Self, BigDecimal>, _ label: String) -> String? {
		guard let value = condAgg(keyPath) else {
			return nil
		}
		return format(xrdAmount: value, label: label)
	}
	
	public var relevantAccounts: [Account] {
		accounts.filter(\.hasAltcoinValueAboveThreshold)
	}
	
	public func accountsDetails(fiat: Fiat) -> String? {
		
		guard !relevantAccounts.isEmpty else {
			return nil
		}
		
		return relevantAccounts
			.map({ $0.details(fiat: fiat) })
			.map { $0.indent(level: 2) }
			.joined(separator: "\n")
	}
	
	public var grandTotalFiatWorth: BigDecimal { xrdValueInSelectedFiat * aggGrandTotal }
	
	public func detailed(fiat: Fiat) -> String? {
		guard
			let grandTotalXRDAmount = condAgg(\.aggGrandTotal)
		else { return nil }
		
		let grandTotalXRDAmountString = format(
			xrdAmount: grandTotalXRDAmount,
			label: "GRAND TOTAL"
		)
		
		let grandTotalFiatWorthString = "GRAND TOTAL: \(grandTotalFiatWorth.format(style: .valueInFiat(fiat)))"
		
		let profileName = "Profile: '\(name)'"
		let availableOrNil = condAggXRDAmountFormatted(\.xrdLiquid, "Available").map { $0 + " (\(accounts.filter { $0.xrdLiquid > thresholdXRDAmount }.map { "\($0.account.nameOrIndex): \($0.xrdLiquid.amountOfXRDFormat)" }.joined(separator: ", ")))" }
		let stakedOrNil = condAggXRDAmountFormatted(\.xrdStaked, "Staked")
		let altsOrNil = condAggXRDAmountFormatted(\.xrdValueOfAllAltcoins, "ALTs")
		let numberOfAccounts = "#\(accounts.count) accounts"
		
		return Array<String?>([
			profileName,
			grandTotalFiatWorthString,
			grandTotalXRDAmountString,
			availableOrNil.indent(),
			stakedOrNil.indent(),
			altsOrNil.indent(),
			numberOfAccounts.indent(),
			accountsDetails(fiat: fiat).map { "Accounts with alts:\n\($0)" }.indent()
		]).compactMap { $0 }
			.joined(separator: "\n")
	}
	
	public func descriptionOrIgnored(fiat: Fiat) -> String {
		guard let detailedDescription = detailed(fiat: fiat) else {
			return "Profile: '\(name)' has not enough value."
		}
		return detailedDescription
	}
}

extension Optional where Wrapped == String {
	
	public func indent(level: Int = 1) -> String? {
		guard let string = self else { return nil }
		return string.indent(level: level)
	}
	
}

extension String {
	public func indent(level: Int = 1) -> String {
		return String(repeating: "\t", count: level) + self
	}
}

