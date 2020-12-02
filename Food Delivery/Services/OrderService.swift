//
//  OrderService.swift
//  Food Delivery
//
//  Created by Steven Brooks on 11/4/20.
//

import Foundation
import Combine

struct OrderService {
	func getAll(for diner: Diner) -> AnyPublisher<[Order]?, Never> {
		// build a query to get user orders
		var components = URLComponents()
		
		components.scheme = URLSession.baseUrl.scheme
		components.host = URLSession.baseUrl.host
		components.path = "/orders.json"
		components.queryItems = [URLQueryItem(name: "orderBy", value: "\"userId\""), URLQueryItem(name: "equalTo", value: "\"\(diner.id)\"")]
		components.authenticate(token: diner.token)
		
		return getAll(from: components)
	}
	
	func getAll(for restaurant: Restaurant) -> AnyPublisher<[Order]?, Never> {
		// build a query to get restaurant orders
		var components = URLComponents()
		
		components.scheme = URLSession.baseUrl.scheme
		components.host = URLSession.baseUrl.host
		components.path = "/orders.json"
		components.queryItems = [URLQueryItem(name: "orderBy", value: "\"restaurantId\""), URLQueryItem(name: "equalTo", value: "\"\(restaurant.id)\"")]
		
		return getAll(from: components)
	}
	
	private func getAll(from components: URLComponents) -> AnyPublisher<[Order]?, Never> {
		return URLSession.shared.dataTaskPublisher(for: components.url!)
			.map{ $0.data }
			.decode(type: [String: Order]?.self, decoder: JSONDecoder())
			.map { $0 != nil ? Array($0!.values) : nil }
			.replaceError(with: nil)
			.eraseToAnyPublisher()
	}
	
	func sumbit(order: Order) -> AnyPublisher<Order?, Never> {
		var request = URLRequest(url: URLSession.baseUrl.appendingPathComponent("orders/\(order.id).json"))
		request.httpMethod = "PUT"
		request.httpBody = try? JSONEncoder().encode(order)
		
		return URLSession.shared.dataTaskPublisher(for: request)
			.map { $0.data }
			.decode(type: Order?.self, decoder: JSONDecoder())
			.replaceError(with: nil)
			.eraseToAnyPublisher()
	}
	
	func updateStatus(for order: Order) -> AnyPublisher<[Order.Status: Date]?, Never> {
		var request = URLRequest(url: URLSession.baseUrl.appendingPathComponent("orders/\(order.id).json"))
		request.httpMethod = "PATCH"
		request.httpBody = try? JSONEncoder().encode(["history": order.history])
		
		do {
			request.httpBody = try JSONEncoder().encode(["history": order.history])
		}
		catch {
			print(error)
		}
		
		return URLSession.shared.dataTaskPublisher(for: request)
			.map { $0.data }
			.decode(type: [String: [Order.Status: Date]]?.self, decoder: JSONDecoder())
			.replaceError(with: nil)
			.map { $0?["history"] }
			.eraseToAnyPublisher()
	}
}
