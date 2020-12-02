//
//  RestaurantOwnerViewModel.swift
//  Food Delivery
//
//  Created by Steven Brooks on 11/3/20.
//

import Foundation
import Combine

class RestaurantOwnerViewModel: ObservableObject {
	@Published var isServiceRunning = false
	
	// CRUD properties
	@Published var addedMeal: Meal? {
		didSet {			
			if addedMeal == nil {
				if isServiceRunning {
					// only show this message as a result of a webservice call
					errorMessage = "There was an error adding the meal"
				} 
			} else {
				restaurant.meals.append(addedMeal!)
			}
			isServiceRunning = false
		}
	}
	
	@Published var deletedMeal: Meal? {
		didSet {
			if deletedMeal == nil {
				if isServiceRunning {
					// only show this message as a result of a webservice call
					errorMessage = "There was an error deleting the meal"
				}
			} else {
				restaurant.meals.removeAll(where: {$0.id == deletedMeal?.id})
			}
			isServiceRunning = false
		}
	}
	
	@Published var updatedMeal: Meal? {
		didSet {
			if updatedMeal == nil {
				if isServiceRunning {
					// only show this message as a result of a webservice call
					errorMessage = "There was an error updating the meal"
				}
			} else {
				// update the resaurant list
				if let index = restaurant.meals.firstIndex(where: { $0.id == updatedMeal!.id }) {
					restaurant.meals[index] = updatedMeal!
				}
			}
			isServiceRunning = false
		}
	}
	
	@Published var showAlert = false {
		didSet {
			// clear triggers
			if !showAlert {
				errorMessage = nil
				mealToDelete = nil
			}
		}
	}
	var errorMessage: String? {
		didSet {
			if errorMessage != nil { showAlert = true }
		}
	}
	var mealToDelete: Meal? {
		didSet {
			if mealToDelete != nil { showAlert = true }
		}
	}
	
	@Published var mealToAddName: String = ""
	@Published var mealToAddDescription: String = ""
	@Published var mealToAddPrice: String = ""
	
	private var cancellables: [AnyCancellable] = []
	private (set) var restaurant: Restaurant

	private var meals: [Meal] = [] {
		didSet {
			isServiceRunning = false
			restaurant.meals = meals
		}
	}

	init(restaurant: Restaurant) {
		self.restaurant = restaurant
	}
	
	func getMeals() {
		isServiceRunning = true
		MealsService().meals(from: restaurant)
			.receive(on: DispatchQueue.main)
			.assign(to: \.meals, on: self)
			.store(in: &cancellables)
	}
	
	func add(meal: Meal) {
		isServiceRunning = true
		MealsService().add(meal: meal, to: restaurant)
			.receive(on: DispatchQueue.main)
			.assign(to: \.addedMeal, on: self)
			.store(in: &cancellables)
	}
	
	func update(meal: Meal) {
		isServiceRunning = true
		MealsService().update(meal: meal, in: restaurant)
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: { [weak self] in
				// if it was successful, just set the updated restaurant
				self?.updatedMeal = $0 ? meal : nil
			})
			.store(in: &cancellables)
	}
	
	func delete(meal: Meal) {
		isServiceRunning = true
		MealsService().delete(meal: meal, from: restaurant)
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: { [weak self] in
				// if it was successful, just set the deleted restaurant
				self?.deletedMeal = $0 ? meal : nil
			})
			.store(in: &cancellables)
	}
	
	func validateMealToAdd() -> Meal? {
		let price = Float(mealToAddPrice)
		
		if mealToAddName.isEmpty {
			errorMessage = "Name cannot be blank"
		}
		else if mealToAddPrice.isEmpty {
			errorMessage = "Price cannot be blank"
		}
		else if price == nil || price! < 0 {
			errorMessage = "Invalid Price"
		}
		else {
			return Meal(name: mealToAddName, description: mealToAddDescription, price: price!)
		}
		
		return nil
	}
	
	func validateMealToEdit(meal: inout Meal) -> Bool {
		let price = Float(mealToAddPrice)
		
		if mealToAddName.isEmpty {
			errorMessage = "Name cannot be blank"
		}
		else if mealToAddPrice.isEmpty {
			errorMessage = "Price cannot be blank"
		}
		else if price == nil || price! < 0 {
			errorMessage = "Invalid Price"
		}
		else {
			meal.name = mealToAddName
			meal.description = mealToAddDescription
			meal.price = price!
			return true
		}
		
		return false
	}
}
