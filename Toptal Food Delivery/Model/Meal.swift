//
//  Meal.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 10/29/20.
//

import Foundation

struct Meal: Codable, Hashable {
	var name: String
	var description: String
	var price: Float
	var id = UUID().uuidString
}

extension Array where Element == Meal {
	var unique: [Meal] {
		Array(Set(self)).sorted(by: {$0.name < $1.name} )
	}
	
	var quantities: [Meal: Int] {
		var result: [Meal: Int] = [:]
		
		for meal in unique {
			result[meal] = filter{$0.name == meal.name}.count
		}
		
		return result
	}
	
	var totalCost: Float {
		map{$0.price}.reduce(0, +)
	}
}
