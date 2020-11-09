//
//  LoginService.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 10/30/20.
//

import Foundation
import Combine

struct LoginService {
	func login<T: User>(username: String, password: String) -> AnyPublisher<T?, Never> {
		let path = T.self == Diner.self ? "users" : "owners"
		let request = URLRequest(url: URLSession.baseUrl.appendingPathComponent("\(path)/\(username.lowercased()).json"))
		
		return URLSession.shared.dataTaskPublisher(for: request)
			.map { $0.data }
			.decode(type: T?.self, decoder: JSONDecoder())
			.replaceError(with: nil)
			.map {
				$0?.password == password ? $0 : nil
			}
			.eraseToAnyPublisher()
	}
}
