//
//  Restaurant.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 10/29/20.
//

import Foundation

struct Restaurant: Codable, Identifiable {
	var name: String
	var owner: String
	var description: String
	var meals: [Meal]
	var id = UUID().uuidString
	var blockedUsers: [String]
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		name = try container.decode(String.self, forKey: .name)
		description = try container.decode(String.self, forKey: .description)
		
		if let mealDict = (try? container.decode([String: Meal].self, forKey: .meals)) {
			meals = Array(mealDict.values)
		} else {
			meals = (try? container.decode([Meal].self, forKey: .meals)) ?? []
		}
		owner = try container.decode(String.self, forKey: .owner)
		id = try container.decode(String.self, forKey: .id)
		
		blockedUsers = (try? container.decode([String].self, forKey: .blockedUsers)) ?? []
	}
	
	init(name: String, description: String, owner: String, meals: [Meal] = []) {
		self.name = name
		self.description = description
		self.owner = owner
		self.meals = meals
		blockedUsers = []
	}
}
