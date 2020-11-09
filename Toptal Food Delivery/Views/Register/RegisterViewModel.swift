//
//  RegisterViewModel.swift
//  Toptal Food Delivery
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
	
	@Published var isServiceRunning = false
	
	enum UserType: String, CaseIterable {
		case diner
		case owner
	}
	
	@Published var userType: UserType = .diner
	@Published var errorMessage: String?
	
	private var cancellables: [AnyCancellable] = []
	
	private var diner: Diner? {
		didSet {
			isServiceRunning = false
		}
	}
	private var owner: Owner? {
		didSet {
			isServiceRunning = false
		}
	}
	
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
		
		return errorMessage == nil
	}
	
	func register() {
		let info = RegistrationInfo(firstName: firstName, lastName: lastName, username: username, password: password)
		
		isServiceRunning = true
		if userType == .diner {
			RegisterService().register(with: info)
				.replaceError(with: nil)
				.assign(to: \.diner, on: self)
				.store(in: &cancellables)
		} else {
			RegisterService().register(with: info)
				.replaceError(with: nil)
				.assign(to: \.owner, on: self)
				.store(in: &cancellables)
		}
	}
}
