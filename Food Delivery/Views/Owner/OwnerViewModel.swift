//
//  OwnerViewModel.swift
//  Food Delivery
//
//  Created by Steven Brooks on 10/30/20.
//

import Foundation
import Combine

class OwnerViewModel: ObservableObject {
	@Published var owner: Owner
	@Published var isServiceRunning = false
	@Published var showAlert = false {
		didSet {
			if showAlert == false {
				// clear all the possible alert trips
				errorMessage = nil
				restaurantToDelete = nil
				showLogoutAlert = false
			}
		}
	}
	
	// CRUD related properties
	@Published var addedRestaurant: Restaurant? {
		didSet {
			if addedRestaurant == nil {
				if isServiceRunning {
					// only show this message as a result of a webservice call
					errorMessage = "There was an error adding the restaurant"
				}
			} else {
				owner.restaurants.append(addedRestaurant!)
			}
			isServiceRunning = false
		}
	}
	
	@Published var deletedRestaurant: Restaurant? {
		didSet {
			if deletedRestaurant == nil {
				if isServiceRunning {
					// only show this message as a result of a webservice call
					errorMessage = "There was an error deleting the restaurant"
				}
			} else {
				owner.restaurants.removeAll(where: {$0.id == deletedRestaurant?.id})
			}
			isServiceRunning = false
		}
	}
	
	@Published var updatedRestaurant: Restaurant? {
		didSet {
			if updatedRestaurant == nil {
				if isServiceRunning {
					// only show this message as a result of a webservice call
					errorMessage = "There was an error updating the restaurant"
				}
			} else {
				// update the resaurant list
				if let index = owner.restaurants.firstIndex(where: { $0.id == updatedRestaurant!.id }) {
					owner.restaurants[index] = updatedRestaurant!
				}
			}
			isServiceRunning = false
		}
	}
	
	@Published var restaurantAddedSuccess = false
	
	// possible alerts
	@Published var errorMessage: String? {
		didSet {
			if errorMessage != nil { showAlert = true }
		}
	}
	@Published var showLogoutAlert = false {
		didSet {
			if showLogoutAlert { showAlert = true }
		}
	}
	@Published var restaurantToDelete: Restaurant? {
		didSet {
			if restaurantToDelete != nil { showAlert = true }
		}
	}
	// end alerts

	// form fields
	@Published var restaurantToAddName: String = ""
	@Published var restaurantToAddDescription: String = ""
	
	private var restaurants: [Restaurant] = [] {
		didSet {
			isServiceRunning = false
			owner.restaurants = restaurants
		}
	}
	
	private var cancellables: [AnyCancellable] = []
	
	init(owner: Owner) {
		self.owner = owner
		getRestaurants()
	}
	
	func getRestaurants() {
		isServiceRunning = true
		RestaurantService().ownedBy(owner: owner)
			.receive(on: DispatchQueue.main)
			.map{ $0 }
			.assign(to: \.restaurants, on: self)
			.store(in: &cancellables)
	}
	
	func add(restaurant: Restaurant) {
		isServiceRunning = true
		RestaurantService().add(restaurant: restaurant)
			.receive(on: DispatchQueue.main)
			.assign(to: \.addedRestaurant, on: self)
			.store(in: &cancellables)
	}
	
	func update(restaurant: Restaurant) {
		isServiceRunning = true
		RestaurantService().update(restaurant: restaurant)
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: { [weak self] in
				// if it was successful, just set the updated restaurant
				self?.updatedRestaurant = $0 ? restaurant : nil
			})
			.store(in: &cancellables)
	}
	
	func delete(restaurant: Restaurant) {
		isServiceRunning = true
		RestaurantService().delete(restaurant: restaurant)
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: { [weak self] in
				// if it was successful, just set the deleted restaurant
				self?.deletedRestaurant = $0 ? restaurant : nil
			})
			.store(in: &cancellables)
	}
	
	func validateRestaurantToAdd() -> Restaurant? {
		if restaurantToAddName.isEmpty {
			errorMessage = "Name cannot be blank"
		}
		else if restaurantToAddDescription.isEmpty {
			errorMessage = "Description cannot be blank"
		}
		else {
			return Restaurant(name: restaurantToAddName, description: restaurantToAddDescription, owner: owner)
		}
		
		return nil
	}
	
	func validateRestaurantToEdit(restaurant: inout Restaurant) -> Bool {
		if restaurantToAddName.isEmpty {
			errorMessage = "Name cannot be blank"
		}
		else if restaurantToAddDescription.isEmpty {
			errorMessage = "Description cannot be blank"
		}
		else {
			restaurant.name = restaurantToAddName
			restaurant.description = restaurantToAddDescription
			return true
		}
		
		return false
	}
}
