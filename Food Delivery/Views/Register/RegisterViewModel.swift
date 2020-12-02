//
//  RegisterViewModel.swift
//  Food Delivery
//
//  Created by Steven Brooks on 10/29/20.
//

import Foundation
import Combine

class RegisterViewModel: ObservableObject {
	@Published var firstName: String = ""
	@Published var lastName: String = ""
	@Published var username: String = ""
	@Published var password: String = ""
	@Published var confirmPassword: String = ""
	
	@Published var isServiceRunning = false
	
	enum UserType: String, CaseIterable {
		case diner
		case owner
	}
	
	@Published var userType: UserType = .diner
	@Published var errorMessage: String?
	
	private var cancellables: [AnyCancellable] = []
	
	@Published var diner: Diner?
	@Published var owner: Owner?
	
	func validate() -> Bool {
		// return any validation errors
		if firstName.isEmpty {
			errorMessage = "First Name is Required"
		}
		else if lastName.isEmpty {
			errorMessage = "Last Name is Required"
		}
		else if username.isEmpty {
			errorMessage = "Username is required"
		}
		else if password.count < 8 {
			errorMessage = "Password must be at least 8 characters"
		}
		else if confirmPassword != password {
			confirmPassword = ""
			errorMessage = "Passwords do not match"
		}
		
		return errorMessage == nil
	}
	
	func register() {
		isServiceRunning = true
		
		if userType == .diner {
			Auth().register(firstName: firstName, lastName: lastName, email: username, password: password)
				.receive(on: DispatchQueue.main)
				.sink(receiveCompletion: { [unowned self] completion in
					isServiceRunning = false
					switch completion {
					case .finished:
						break
					case .failure(let error):
						errorMessage = error.localizedDescription
					}
				}, receiveValue: { [unowned self] user in
					diner = user
				})
				.store(in: &cancellables)
		} else {
			Auth().register(firstName: firstName, lastName: lastName, email: username, password: password)
				.receive(on: DispatchQueue.main)
				.sink(receiveCompletion: { [unowned self] completion in
					switch completion {
					case .finished:
						isServiceRunning = false
					case .failure(let error):
						errorMessage = error.localizedDescription
					}
				}, receiveValue: { [unowned self] user in
					diner = user
				})
				.store(in: &cancellables)
		}
	}
}
