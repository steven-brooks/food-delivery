//
//  User.swift
//  Food Delivery
//
//  Created by Steven Brooks on 11/2/20.
//

import Foundation

protocol User: Codable, Identifiable {
	var id: String { get set }
	
	var firstName: String { get set }
	var lastName: String { get set }
	var email: String { get set }
	var token: String! { get set }
	
	func tokenize(_ token: String) -> Self
}

extension User {
	func tokenize(_ token: String) -> Self {
		var user = self
		user.token = token
		return user
	}
}
