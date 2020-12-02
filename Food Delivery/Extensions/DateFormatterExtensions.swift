//
//  DateFormatterExtensions.swift
//  Food Delivery
//
//  Created by Steven Brooks on 11/6/20.
//

import Foundation

extension DateFormatter {
	static var shortFormatter: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .short
		return formatter
	}
}
