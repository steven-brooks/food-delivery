//
//  RestaurantsViewModel.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 11/2/20.
//

import Foundation
import Combine

class RestaurantsViewModel: ObservableObject {
	@Published var restaurants: [Restaurant] = [] {
		didSet {
			isServiceActive = false
		}
	}
	@Published var isServiceActive = false
	
	func availableRestaurants(for diner: Diner) -> [Restaurant] {
		restaurants.filter{!$0.blockedUsers.contains(diner.username)}
	}

	private var cancellables: [AnyCancellable] = []
	
	init(restaurants: [Restaurant] = []) {
		self.restaurants = restaurants
		fetchRestaurants()
	}
	
	func fetchRestaurants() {
		// fetch the list of restaurants
		isServiceActive = true
		RestaurantService().fetchAll()
			.receive(on: DispatchQueue.main)
			.assign(to: \.restaurants, on: self)
			.store(in: &cancellables)
	}
}
