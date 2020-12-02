//
//  LoginService.swift
//  Food Delivery
//
//  Created by Steven Brooks on 10/30/20.
//

import Foundation
import Combine
import FirebaseAuth

enum AuthError: Error {
	case invalidUserError
}

class Auth {
	static var cancellables: [AnyCancellable] = []
	
	func register<T: User>(firstName: String, lastName: String, email: String, password: String) -> Future<T, Error> {
		return Future<T, Error> { promise in
			FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
				if let error = error {
					promise(.failure(error))
					return
				}
				
				guard let user = result?.user else {
					promise(.failure(AuthError.invalidUserError))
					return
				}
				
				result?.user.getIDToken(completion: { (token, error) in
					if let error = error {
						promise(.failure(error))
					}
					
					let info = RegistrationInfo(firstName: firstName, lastName: lastName, email: email, id: user.uid)
					LoginService().register(with: info, token: token!)
						.sink { (completion) in
							switch completion {
							case .finished:
								break
							case .failure(let error):
								promise(.failure(error))
							}
						} receiveValue: { (value) in
							promise(value != nil ? .success(value!) : .failure(AuthError.invalidUserError))
						}
						.store(in: &Auth.cancellables)
				})
			}
		}
	}
	
	func login<T: User>(email: String, password: String) -> Future<T, Error> {
		return Future<T, Error> { promise in
			FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
				if let error = error {
					promise(.failure(error))
					return
				}
				
				guard let user = result?.user else {
					promise(.failure(AuthError.invalidUserError))
					return
				}
				
				result?.user.getIDToken(completion: { (token, error) in
					if let error = error {
						promise(.failure(error))
					}
					
					LoginService().getUser(id: user.uid, token: token!)
						.sink { (completion) in
							switch completion {
							case .finished:
								break
							case .failure(let error):
								promise(.failure(error))
							}
						} receiveValue: { (value) in
							promise(value != nil ? .success(value!) : .failure(AuthError.invalidUserError))
						}
						.store(in: &Auth.cancellables)
				})
			}
		}
	}
}

fileprivate struct LoginService {
	func getUser<T: User>(id: String, token: String) -> AnyPublisher<T?, Never> {
		let path = T.self == Diner.self ? "users" : "owners"
		var request = URLRequest(url: URLSession.baseUrl.appendingPathComponent("\(path)/\(id).json"))
		request.authenticate(token: token)
		
		return URLSession.shared.dataTaskPublisher(for: request)
			.map { $0.data }
			.decode(type: T?.self, decoder: JSONDecoder())
			.replaceError(with: nil)
			.map{ $0?.tokenize(token) }
			.eraseToAnyPublisher()
	}
	
	func register<T: User>(with info: RegistrationInfo, token: String) -> AnyPublisher<T?, Never> {
		let path = T.self == Diner.self ? "users" : "owners"
		
		var request = URLRequest(url: URLSession.baseUrl.appendingPathComponent("\(path)/\(info.id).json"))
		request.httpMethod = "PUT"
		request.httpBody = try? JSONEncoder().encode(info)
		request.authenticate(token: token)
		
		return URLSession.shared.dataTaskPublisher(for: request)
			.map { $0.data }
			.decode(type: T?.self, decoder: JSONDecoder())
			.replaceError(with: nil)
			.eraseToAnyPublisher()
	}
}
