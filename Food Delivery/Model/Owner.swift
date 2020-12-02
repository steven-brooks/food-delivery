//
//  Owner.swift
//  Food Delivery
//
//  Created by Steven Brooks on 10/29/20.
//

import Foundation

struct Owner: User {
	var firstName: String
	var lastName: String
	var email: String
	var token: String!
	var restaurants: [Restaurant] = []
	var id = UUID().uuidString
	
	var name: String {
		"\(firstName) \(lastName)"
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		firstName = try container.decode(String.self, forKey: .firstName)
		lastName = try container.decode(String.self, forKey: .lastName)
		email = try container.decode(String.self, forKey: .email)
		id = try container.decode(String.self, forKey: .id)
		
		restaurants = (try? container.decode([Restaurant].self, forKey: .restaurants)) ?? []
	}
	
	init(firstName: String, lastName: String, email: String, restaurants: [Restaurant] = []) {
		self.firstName = firstName
		self.lastName = lastName
		self.email = email
		self.restaurants = restaurants
	}
}
