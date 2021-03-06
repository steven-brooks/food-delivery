//
//  LoginViewModel.swift
//  Food Delivery
//
//  Created by Steven Brooks on 10/29/20.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject {
	@Published var username: String = ""
	@Published var password: String = ""
	@Published var errorMessage: String?
	@Published var isServiceRunning = false
	@Published var rememberUsername = false
	@Published var validUser = false
	
	@Published var owner: Owner? {
		didSet {
			if owner == nil {
				// 2: if not, see if it's a diner login
				loginDiner()
			} else {
				isServiceRunning = false
				validUser = true
				saveUsername()
			}
		}
	}
	@Published var diner: Diner? {
		didSet {
			isServiceRunning = false
			if diner == nil {
				errorMessage = "Invalid username or password"
				password = ""
				clearUsername()
			}
			else {
				validUser = true
				saveUsername()
			}
		}
	}

	private var cancellables: [AnyCancellable] = []
	
	init() {
		rememberUsername = UserDefaults.standard.bool(forKey: "rememberUsername")
		
		if rememberUsername {
			username = UserDefaults.standard.string(forKey: "username") ?? ""
		}
	}
	
	func login() {
		if username.isEmpty {
			errorMessage = "Please enter a valid username"
		}
		else if password.isEmpty {
			errorMessage = "Please enter a password"
		}
		else {
			isServiceRunning = true
			
			// 1: check to see if they're an owner first
			Auth().login(email: username, password: password)
				.receive(on: DispatchQueue.main)
				.sink { [unowned self] (completion) in
					isServiceRunning = false
					switch completion {
					case .finished:
						break
					case .failure:
						// 2. try a regular diner
						loginDiner()
					}
				} receiveValue: { [unowned self] (value) in
					owner = value
				}
				.store(in: &cancellables)
		}
	}
	
	private func loginDiner() {
		isServiceRunning = true
		Auth().login(email: username, password: password)
			.receive(on: DispatchQueue.main)
			.sink { [unowned self] (completion) in
				isServiceRunning = false
				switch completion {
				case .finished:
					break
				case .failure(let error):
					errorMessage = error.localizedDescription
				}
			} receiveValue: { [unowned self] (value) in
				diner = value
			}
			.store(in: &cancellables)
	}
	
	private func saveUsername() {
		if rememberUsername {
			UserDefaults.standard.set(true, forKey: "rememberUsername")
			UserDefaults.standard.set(username, forKey: "username")
		} else {
			UserDefaults.standard.removeObject(forKey: "rememberUsername")
			UserDefaults.standard.removeObject(forKey: "username")
		}
		
		#if targetEnvironment(simulator)
		UserDefaults.standard.synchronize()
		#endif
	}
	
	private func clearUsername() {
		UserDefaults.standard.removeObject(forKey: "username")
	}
}
