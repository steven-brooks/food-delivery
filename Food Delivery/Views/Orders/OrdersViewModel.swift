//
//  OrdersViewModel.swift
//  Food Delivery
//
//  Created by Steven Brooks on 11/5/20.
//

import Foundation
import Combine

class OrdersViewModel: ObservableObject {
	@Published var orders: [Order]? {
		didSet {
			isServiceActive = false
		}
	}
	@Published var isServiceActive = false
	private var cancellables: [AnyCancellable] = []
	private var diner: Diner?
	private (set) var restaurant: Restaurant?
	
	var isRestaurant: Bool { restaurant != nil }
	
	init(diner: Diner) {
		self.diner = diner
		getOrders()
	}
	
	init(restaurant: Restaurant) {
		self.restaurant = restaurant
		getOrders()
	}
	
	func getOrders() {
		isServiceActive = true
		
		if let diner = diner {
			OrderService().getAll(for: diner)
				.receive(on: DispatchQueue.main)
				.assign(to: \.orders, on: self)
				.store(in: &cancellables)
		}
		else if let restaurant = restaurant {
			OrderService().getAll(for: restaurant)
				.receive(on: DispatchQueue.main)
				.assign(to: \.orders, on: self)
				.store(in: &cancellables)
		}
	}
	
	func update(order: Order) {
		if let index = orders?.firstIndex(where: {$0.orderId == order.orderId}) {
			orders?[index] = order
		}
	}
}
