//
//  User.swift
//  Food Delivery
//
//  Created by Steven Brooks on 10/29/20.
//

import Foundation

struct Diner: User {
	var firstName: String
	var lastName: String
	var email: String
	var token: String!
	
	var orders: [Order]
	var id = UUID().uuidString
	
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		firstName = try container.decode(String.self, forKey: .firstName)
		lastName = try container.decode(String.self, forKey: .lastName)
		email = try container.decode(String.self, forKey: .email)
		id = try container.decode(String.self, forKey: .id)
		
		orders = (try? container.decode([Order].self, forKey: .orders)) ?? []
	}
	
	init(firstName: String, lastName: String, email: String) {
		self.firstName = firstName
		self.lastName = lastName
		self.email = email
		
		orders = []
	}
}
