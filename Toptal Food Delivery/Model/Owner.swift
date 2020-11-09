//
//  Owner.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 10/29/20.
//

import Foundation

struct Owner: User {
	var firstName: String
	var lastName: String
	var username: String
	var password: String
	var restaurants: [Restaurant] = []
	var id = UUID().uuidString
	
	var name: String {
		"\(firstName) \(lastName)"
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		firstName = try container.decode(String.self, forKey: .firstName)
		lastName = try container.decode(String.self, forKey: .lastName)
		username = try container.decode(String.self, forKey: .username)
		password = try container.decode(String.self, forKey: .password)
		
		restaurants = (try? container.decode([Restaurant].self, forKey: .restaurants)) ?? []
	}
	
	init(firstName: String, lastName: String, username: String, password: String, restaurants: [Restaurant] = []) {
		self.firstName = firstName
		self.lastName = lastName
		self.username = username
		self.password = password
		self.restaurants = restaurants
	}
}
