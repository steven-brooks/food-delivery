//
//  OrderViewModel.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 11/6/20.
//

import Foundation
import Combine

class OrderStatusViewModel: ObservableObject {
	@Published var order: Order
	
	@Published var showAlert = false {
		didSet {
			if !showAlert {
				// clear triggers
				confirmationAlert = nil
				errorMessage = nil
				blockUserAlert = false
			}
		}
	}
	
	var confirmationAlert: Order.Status.Action? {
		didSet {
			if confirmationAlert != nil {
				showAlert = true
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
	var blockUserAlert = false {
		didSet {
			if blockUserAlert {
				showAlert = true
			}
		}
	}
	
	@Published var isServiceActive = false
	@Published var updateResult: [Order.Status: Date]? {
		didSet {
			if isServiceActive, updateResult == nil {
				errorMessage = "There was an error updating the status"
			}
			isServiceActive = false
			// status successfully changed
			if updateResult?.keys.contains(.cancelled) ?? false {
				successMessage = "Order Cancelled"
			}
			else if updateResult?.keys.contains(.completed) ?? false {
				successMessage = "Enjoy!"
			}
			else {
				successMessage = "Status Updated"
			}
			
			onOrderUpdated?(order)
		}
	}
	@Published var successMessage: String?
	@Published var userBlockedSuccess: String?
	
	// user status changes end the order
	var dismissOnChange: Bool { !isRestaurant }
	
	private var cancellables: [AnyCancellable] = []

	var restaurant: Restaurant?
	var isRestaurant: Bool { restaurant != nil }
	@Published var blockSuccess: Bool = false {
		didSet {
			if !blockSuccess {
				errorMessage = "There was an error updating user permissions"
			} else {
				if restaurant?.blockedUsers.contains(order.username) ?? false {
					userBlockedSuccess = "User Blocked!"
				} else {
					userBlockedSuccess = "User Unblocked!"
				}
			}
		}
	}
	
	init(order: Order, restaurant: Restaurant? = nil) {
		self.restaurant = restaurant
		self.order = order
	}
	
	func performAction() {
		if let action = order.status.nextAction(isRestaurant: isRestaurant) {
			if action.isDestructive {
				confirmationAlert = action
			} else {
				update(to: action.status)
			}
		}
	}
	
	func performConfirmationAction() {
		// user said yes to the destructive action
		if let action = order.status.nextAction(isRestaurant: isRestaurant) {
			if action == .cancel {
				update(to: .cancelled)
			}
		}
	}
	
	private func update(to status: Order.Status) {
		// track the history
		order.history[status] = Date()
		isServiceActive = true
		OrderService().updateStatus(for: order)
			.receive(on: DispatchQueue.main)
			.assign(to: \.updateResult, on: self)
			.store(in: &cancellables)
	}
	
	// order status change callback
	private var onOrderUpdated: ((Order) -> ())?
	
	func onOrderUpdated(_ block: @escaping (Order) -> ()) -> Self {
		onOrderUpdated = block
		return self
	}
	
	func toggleUserBlocked() {
		if restaurant != nil {
			if restaurant!.blockedUsers.contains(order.username) {
				restaurant!.blockedUsers.removeAll(where: {$0 == order.username})
			} else {
				restaurant!.blockedUsers.append(order.username)
			}
			
			RestaurantService().update(restaurant: restaurant!)
				.receive(on: DispatchQueue.main)
				.assign(to: \.blockSuccess, on: self)
				.store(in: &cancellables)
		}
	}
}
