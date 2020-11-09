//
//  OrderSession.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 11/4/20.
//

import Foundation
import Combine

class OrderSession: ObservableObject {
	@Published var diner: Diner
	@Published var order: Order?
	@Published var isSubmittingOrder = false
	
	// alerting properties
	@Published var showAlert = false {
		didSet {
			if !showAlert {
				errorMessage = nil
				orderStartedFromDifferentRestaurant = false
				showLogoutAlert = false
			}
		}
	}
	
	var errorMessage: String? {
		didSet {
			if errorMessage != nil {
				showAlert = true
			}
		}
	}

	var orderStartedFromDifferentRestaurant = false {
		didSet {
			if orderStartedFromDifferentRestaurant {
				showAlert = true
			}
		}
	}
	
	var showLogoutAlert = false {
		didSet {
			if showLogoutAlert {
				showAlert = true
			}
		}
	}
	
	// cart related alert
	@Published var showCartAlert = false {
		didSet {
			if !showCartAlert {
				cartErrorMessage = nil
				deleteMealConfirmation = nil
	
			}
		}
	}
	
	var cartErrorMessage: String? {
		didSet {
			if cartErrorMessage != nil {
				showCartAlert = true
			}
		}
	}

	var deleteMealConfirmation: Meal? {
		didSet {
			if deleteMealConfirmation != nil {
				showCartAlert = true
			}
		}
	}
	
	//
	
	@Published var submittedOrder: Order? {
		didSet {
			isSubmittingOrder = false
			if submittedOrder == nil {
				cartErrorMessage = "There was an error submitting the order"
			}
		}
	}
	
	private var cache: [Restaurant] = []
	private var cancellables: [AnyCancellable] = []
	
	init(diner: Diner) {
		self.diner = diner
	}
	
	func add(meal: Meal, from restaurant: Restaurant) {
		if order == nil {
			order = Order(restaurant: restaurant, diner: diner)
		}
		
		// check if user is trying to order from a different
		// restaurant than one they's started an order from
		if restaurant.name != order?.restaurantName {
			orderStartedFromDifferentRestaurant = true
		} else {
			order?.meals.append(meal)
		}
	}
	
	func increment(meal: Meal) {
		order?.meals.append(meal)
	}
	
	func decrement(meal: Meal) {
		if let index = order?.meals.firstIndex(of: meal) {
			order?.meals.remove(at: index)
		}
	}
	
	func submitOrder() {
		// set the order date
		order?.history[.placed] = Date()
		
		guard let order = order else {
			errorMessage = "There is no valid order"
			return
		}
		
		isSubmittingOrder = true
		OrderService().sumbit(order: order)
			.receive(on: DispatchQueue.main)
			.assign(to: \.submittedOrder, on: self)
			.store(in: &cancellables)
	}
}
