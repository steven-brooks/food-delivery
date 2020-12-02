//
//  RestaurantViewModel.swift
//  Food Delivery
//
//  Created by Steven Brooks on 11/4/20.
//

import Foundation
import  Combine

class RestaurantViewModel: ObservableObject {
	@Published var restaurant: Restaurant
	private var cancellables: [AnyCancellable] = []
	
	init(restaurant: Restaurant) {
		self.restaurant = restaurant
	}
	
	func fetchMeals() {
		MealsService().meals(from: restaurant)
			.receive(on: DispatchQueue.main)
			.assign(to: \.restaurant.meals, on: self)
			.store(in: &cancellables)
	}
}
