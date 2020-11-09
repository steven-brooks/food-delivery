//
//  RegisterService.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 10/30/20.
//

import Foundation
import Combine

struct RegisterService {
	
	func register<T: User>(with info: RegistrationInfo) -> AnyPublisher<T?, Never> {
		let path = T.self == Diner.self ? "users" : "owners"
		
		var request = URLRequest(url: URLSession.baseUrl.appendingPathComponent("\(path)/\(info.username).json"))
		request.httpMethod = "PUT"
		request.httpBody = try? JSONEncoder().encode(info)
		
		return URLSession.shared.dataTaskPublisher(for: request)
			.map { $0.data }
			.decode(type: T?.self, decoder: JSONDecoder())
			.replaceError(with: nil)
			.eraseToAnyPublisher()
	}
}
