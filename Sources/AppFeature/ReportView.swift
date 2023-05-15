//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-15.
//

import Foundation
import Backend
import SwiftUI
import BigDecimal

struct ReportView: SwiftUI.View {
	let report: Report
	let fiat: Fiat
}

extension ReportView {
	var accounts: [Report.Account] {
		report.accounts
	}
}

extension Font {
	static func ubuntu(_ size: CGFloat) -> Self {
		.custom("Ubuntu", size: size)
	}
}

extension ReportView {
	
	@ViewBuilder
	var body: some SwiftUI.View {
		VStack(alignment: .leading, spacing: 32) {
			
			VStack(alignment: .leading, spacing: 16) {
				hPair("∑", fiat: \.grandTotalFiatWorth)
				
				hPair("∑", xrd: \.aggGrandTotal)
			}
			.font(.ubuntu(65))
			
			VStack(alignment: .leading, spacing: 8) {
				Text("#\(accounts.count) accounts")
				hPair("Staked", xrd: \.xrdStaked)
				hPair("ALTs", xrd: \.xrdValueOfAllAltcoins)
			}
			.font(.ubuntu(45))
			
			LazyVStack(alignment: .leading, spacing: 24) {
				ForEach(report.relevantAccounts, id: \.self) { account in
					let acc = account.account
					VStack(alignment: .leading) {
						
						HPair(acc.nameOrIndex, value: acc.shortAddress)
							.font(.ubuntu(32))
						
						VStack(alignment: .leading, spacing: 12) {
							ForEach(account.altcoinBalances, id: \.self) { altBal in
								HStack {
									Text(altBal.returnOnInvestment.map { $0.goodInvestment ? "📈" : "📉" } ?? "🆓")
									Text("`\(altBal.tokenInfo.symbol.uppercased())`")
										.font(.headline)
									Group {
										Text(altBal.amountOfAltcoinWithPurchaseIfAny)
										Text(altBal.worthInXRD.amountOfXRDFormat)
										Text(altBal.worth(in: self.report.usdValueInSelectedFiat).format(style: .valueInFiat(fiat)))
									}.font(.body)
									
									if let roi = altBal.returnOnInvestment {
										Text("\(roi.roiFormat)")
											.font(.title3)
											.foregroundColor(roi.goodInvestment ? Color.green : Color.red)
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

extension BigDecimal {
	var goodInvestment: Bool {
		self >= BigDecimal.ONE
	}
	var badInvestment: Bool {
		self < BigDecimal.ONE
		
	}
}

extension ReportView {
	@ViewBuilder
	func hPair(
		_ title: String,
		xrd keyPath: KeyPath<Report, BigDecimal>
	) -> some View {
		HPair(title, xrd: report[keyPath: keyPath])
	}
	
	@ViewBuilder
	func hPair(
		_ title: String,
		fiat keyPath: KeyPath<Report, BigDecimal>
	) -> some View {
		HPair(title, fiat: report[keyPath: keyPath])
	}
}

struct HPair: View {
	let title: String
	let value: String
	init(_ title: String, value: String) {
		self.title = title
		self.value = value
	}
	init<Value>(_ title: String, value: Value) where Value: CustomStringConvertible {
		self.init(title, value: String(describing: value))
	}
				
	init(_ title: String, xrd: BigDecimal) {
		self.init(title, value: xrd.amountOfXRDFormat)
	}
	
	init(_ title: String, fiat: BigDecimal) {
		self.init(title, value: fiat.format(style: .valueInFiat(UserDefaults.standard.fiat)))
	}
				
	var body: some View {
		HStack {
			Text(title)
			Text(value)
		}
	}
}
