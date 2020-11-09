//
//  User.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 11/2/20.
//

import Foundation

protocol User: Codable, Identifiable {
	var id: String { get set }
	
	var firstName: String { get set }
	var lastName: String { get set }
	var username: String { get set }
	var password: String { get set }
}
