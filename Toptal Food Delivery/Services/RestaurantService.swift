//
//  RestaurantService.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 11/1/20.
//

import Foundation

import Combine

struct RestaurantService {
	func ownedBy(owner: Owner) -> AnyPublisher<[Restaurant], Never> {
		
		var components = URLComponents()
		components.scheme = URLSession.baseUrl.scheme
		components.host = URLSession.baseUrl.host
		components.path = "/restaurants.json"
		components.queryItems = [URLQueryItem(name: "orderBy", value: "\"owner\""), URLQueryItem(name: "equalTo", value: "\"\(owner.username)\"")]
		
		let request = URLRequest(url: components.url!)
		
		return URLSession.shared.dataTaskPublisher(for: request)
			.map { $0.data }
			.decode(type: [String: Restaurant].self, decoder: JSONDecoder())
			.map { Array($0.values.sorted(by: { $0.name < $1.name })) }
			.replaceError(with: [])
			.eraseToAnyPublisher()
	}
	
	func fetchAll() -> AnyPublisher<[Restaurant], Never> {
		let request = URLRequest(url: URLSession.baseUrl.appendingPathComponent("restaurants.json"))
		
		return URLSession.shared.dataTaskPublisher(for: request)
			.map {
				$0.data
			}
			.decode(type: [String: Restaurant].self, decoder: JSONDecoder())
			.map { Array($0.values.sorted(by: { $0.name < $1.name })) }
			.replaceError(with: [])
			.eraseToAnyPublisher()
	}
	
	func add(restaurant: Restaurant) -> AnyPublisher<Restaurant?, Never> {
		var request = URLRequest(url: URLSession.baseUrl.appendingPathComponent("restaurants/\(restaurant.id).json"))
		request.httpMethod = "PUT"
		request.httpBody = try? JSONEncoder().encode(restaurant)
		
		return URLSession.shared.dataTaskPublisher(for: request)
			.map { $0.data }
			.decode(type: Restaurant?.self, decoder: JSONDecoder())
			.replaceError(with: nil)
			.eraseToAnyPublisher()
	}
	
	func update(restaurant: Restaurant) -> AnyPublisher<Bool, Never> {
		// don't patch the meals
		struct PatchRestaurant: Encodable {
			var name: String
			var description: String
			var blockedUsers: [String]
			
			init(_ restaurant: Restaurant) {
				name = restaurant.name
				description = restaurant.description
				blockedUsers = restaurant.blockedUsers
			}
		}
		
		var request = URLRequest(url: URLSession.baseUrl.appendingPathComponent("restaurants/\(restaurant.id).json"))
		request.httpMethod = "PATCH"
		request.httpBody = try? JSONEncoder().encode(PatchRestaurant(restaurant))
		
		return URLSession.shared.dataTaskPublisher(for: request)
			// just look for a 200
			.map { (($1 as? HTTPURLResponse)?.statusCode ?? 0) / 100 == 2}
			.replaceError(with: false)
			.eraseToAnyPublisher()
	}
	
	func delete(restaurant: Restaurant) -> AnyPublisher<Bool, Never> {
		var request = URLRequest(url: URLSession.baseUrl.appendingPathComponent("restaurants/\(restaurant.id).json"))
		request.httpMethod = "DELETE"
	
		return URLSession.shared.dataTaskPublisher(for: request)
			// just look for a 200
			.map { (($1 as? HTTPURLResponse)?.statusCode ?? 0) / 100 == 2}
			.replaceError(with: false)
			.eraseToAnyPublisher()
	}
}
