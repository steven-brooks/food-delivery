//
//  MealsService.swift
//  Food Delivery
//
//  Created by Steven Brooks on 11/3/20.
//

import Foundation
import Combine

struct MealsService {
	func meals(from restaurant: Restaurant) -> AnyPublisher<[Meal], Never> {
		let url = URLSession.baseUrl
			.appendingPathComponent("restaurants")
			.appendingPathComponent(restaurant.id)
			.appendingPathComponent("meals.json")
		
		return URLSession.shared.dataTaskPublisher(for: URLRequest(url: url))
			.map { $0.data }
			.decode(type: [String: Meal].self, decoder: JSONDecoder())
			.map { Array($0.values.sorted(by: {$0.name < $1.name})) }
			.replaceError(with: [])
			.eraseToAnyPublisher()
	}
	
	func add(meal: Meal, to restaurant: Restaurant) -> AnyPublisher<Meal?, Never> {
		let url = URLSession.baseUrl
			.appendingPathComponent("restaurants")
			.appendingPathComponent(restaurant.id)
			.appendingPathComponent("meals")
			.appendingPathComponent("\(meal.id).json")
		
		var request = URLRequest(url: url)
		if let token = restaurant.owner?.token {
			request.authenticate(token: token)
		}
		request.httpMethod = "PUT"
		request.httpBody = try? JSONEncoder().encode(meal)
		
		return URLSession.shared.dataTaskPublisher(for: request)
			.map { $0.data }
			.decode(type: Meal?.self, decoder: JSONDecoder())
			.replaceError(with: nil)
			.eraseToAnyPublisher()
	}
	
	func update(meal: Meal, in restaurant: Restaurant) -> AnyPublisher<Bool, Never> {
		let url = URLSession.baseUrl
			.appendingPathComponent("restaurants")
			.appendingPathComponent(restaurant.id)
			.appendingPathComponent("meals")
			.appendingPathComponent("\(meal.id).json")
		
		var request = URLRequest(url:url)
		if let token = restaurant.owner?.token {
			request.authenticate(token: token)
		}
		request.httpMethod = "PATCH"
		request.httpBody = try? JSONEncoder().encode(meal)
		
		return URLSession.shared.dataTaskPublisher(for: request)
			// just look for a 200
			.map { (($1 as? HTTPURLResponse)?.statusCode ?? 0) / 100 == 2}
			.replaceError(with: false)
			.eraseToAnyPublisher()
	}
	
	func delete(meal: Meal, from restaurant: Restaurant) -> AnyPublisher<Bool, Never> {
		let url = URLSession.baseUrl
			.appendingPathComponent("restaurants")
			.appendingPathComponent(restaurant.id)
			.appendingPathComponent("meals")
			.appendingPathComponent("\(meal.id).json")
		
		var request = URLRequest(url: url)
		if let token = restaurant.owner?.token {
			request.authenticate(token: token)
		}
		request.httpMethod = "DELETE"
	
		return URLSession.shared.dataTaskPublisher(for: request)
			// just look for a 200
			.map { (($1 as? HTTPURLResponse)?.statusCode ?? 0) / 100 == 2}
			.replaceError(with: false)
			.eraseToAnyPublisher()
	}
}
