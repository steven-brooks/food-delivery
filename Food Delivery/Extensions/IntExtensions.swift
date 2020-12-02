//
//  IntExtensions.swift
//  Food Delivery
//
//  Created by Steven Brooks on 11/2/20.
//

import Foundation

extension Int {
	static postfix func ++(value: inout Int) -> Int {
		defer {
			value += 1
		}
		return value
	}
	
	static prefix func ++(value: inout Int) -> Int {
		value += 1
		return value
	}
}
