//
//  User.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 10/29/20.
//

import Foundation

struct Diner: User {
	var firstName: String
	var lastName: String
	var username: String
	var password: String
	
	var orders: [Order]
	var id = UUID().uuidString
	
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		firstName = try container.decode(String.self, forKey: .firstName)
		lastName = try container.decode(String.self, forKey: .lastName)
		username = try container.decode(String.self, forKey: .username)
		password = try container.decode(String.self, forKey: .password)
		
		orders = (try? container.decode([Order].self, forKey: .orders)) ?? []
	}
	
	init(firstName: String, lastName: String, username: String, password: String) {
		self.firstName = firstName
		self.lastName = lastName
		self.username = username
		self.password = password
		
		orders = []
	}
}
