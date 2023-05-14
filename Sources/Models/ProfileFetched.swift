//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-13.
//

import Foundation
import BigDecimal

struct ProfileFetched: CustomStringConvertible {
	struct Account: Hashable {
		
		let account: Profile.Account
		let xrdLiquid: BigDecimal
		let xrdStaked: BigDecimal
		let altcoinBalances: [AltcoinBalance]
		
		var hasAltcoinValueAboveThreshold: Bool {
			!altcoinBalances.isEmpty
		}
		
		var xrdValueOfAllAltCoins: BigDecimal {
			altcoinBalances.map(\.worthInXRD).reduce(BigDecimal.ZERO, +)
		}

		init(
			account: Profile.Account,
			xrdLiquid: BigDecimal,
			xrdStaked: BigDecimal,
			altcoinBalances: [AltcoinBalance]
		) {
			precondition(altcoinBalances.allSatisfy({ $0.worthInXRD > thresholdValueInUSD }))
			self.account = account
			self.xrdLiquid = xrdLiquid
			self.xrdStaked = xrdStaked
			self.altcoinBalances = altcoinBalances
		}
		
		var detailed: String {
			"\(account):\n\(altcoinBalances.map(\.detailed).map{ $0.indent(level: 3) }.joined(separator: "\n"))"
		}
	}
	
	/// Name of "Profile" / "wallet"
	let name: String
	
	/// All accounts associated with this profile/wallet.
	let accounts: [Account]
	
	var xrdLiquid: BigDecimal {
		accounts.reduce(BigDecimal(0)) { $0 + $1.xrdLiquid }
	}
	var xrdStaked: BigDecimal {
		accounts.reduce(BigDecimal(0)) { $0 + $1.xrdStaked }
	}
	
	private func condAgg(_ keyPath: KeyPath<Self, BigDecimal>) -> BigDecimal? {
		let value = self[keyPath: keyPath]
		guard value > aggThresholdXRDAmount else {
			return nil
		}
		return value
	}
	private var aggXRDAvailable: BigDecimal? {
		condAgg(\.xrdLiquid)
	}
	private var aggXRDStaked: BigDecimal? {
		condAgg(\.xrdStaked)
	}
	private var aggGrandTotal: BigDecimal {
		xrdLiquid + xrdStaked + xrdValueOfAllAltcoins
	}
	var xrdValueOfAllAltcoins: BigDecimal {
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
	
	private var relevantAccounts: [Account] {
		accounts.filter(\.hasAltcoinValueAboveThreshold)
	}
	var accountsDetails: String? {
		
		guard !relevantAccounts.isEmpty else {
			return nil
		}
	
		return relevantAccounts
			.map(\.detailed)
			.map { $0.indent(level: 2) }
			.joined(separator: "\n")
	}
	
	
	
	var detailed: String? {
		guard let grandTotalXRDAmount = condAgg(\.aggGrandTotal) else { return nil }
		let grandTotal = format(xrdAmount: grandTotalXRDAmount, label: "GRAND TOTAL")

		let profileName = "Profile: '\(name)'"
		let availableOrNil = condAggXRDAmountFormatted(\.xrdLiquid, "Available").map { $0 + " (\(accounts.filter { $0.xrdLiquid > thresholdXRDAmount }.map { "\($0.account.nameOrIndex): \($0.xrdLiquid.amountOfXRDFormat)" }.joined(separator: ", ")))" }
		let stakedOrNil = condAggXRDAmountFormatted(\.xrdStaked, "Staked")
		let altsOrNil = condAggXRDAmountFormatted(\.xrdValueOfAllAltcoins, "ALTs")
		let numberOfAccounts = "#\(accounts.count) accounts"
		
		return Array<String?>([
			profileName,
			grandTotal,
			availableOrNil.indent(),
			stakedOrNil.indent(),
			altsOrNil.indent(),
			numberOfAccounts.indent(),
			accountsDetails.map { "Accounts with alts:\n\($0)" }.indent()
		]).compactMap { $0 }
			.joined(separator: "\n")
	}
	
	var description: String {
		guard let detailed else {
			return "Profile: '\(name)' has not enough value."
		}
		return detailed
	}
}

extension Optional where Wrapped == String {
	
	func indent(level: Int = 1) -> String? {
		guard let string = self else { return nil }
		return string.indent(level: level)
	}

}

extension String {
	func indent(level: Int = 1) -> String {
		return String(repeating: "\t", count: level) + self
	}
}

