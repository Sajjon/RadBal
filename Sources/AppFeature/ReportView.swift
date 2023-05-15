//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-05-15.
//

import Foundation
import Backend
import SwiftUI

struct ReportView: SwiftUI.View {
	let report: Report
	var body: some View {
		Text("\(report.descriptionOrIgnored(fiat: UserDefaults.defaultFiat))")
	}
}

