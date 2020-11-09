//
//  Order.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 11/2/20.
//

import Foundation

struct Order: Codable {
	enum Status: String, Codable, CaseIterable {
		case cancelled
		case placed
		case processed
		case enroute
		case delivered
		case completed
		
		@discardableResult mutating func advance() -> Status {
			if let index = Status.allCases.firstIndex(of: self) {
				if index < Status.allCases.count - 1 {
					self = Status.allCases[index + 1]
				}
			}
			return self
		}
		
		enum Action: String, Identifiable {
			case cancel			= "Cancel"
			case markProcessing	= "Mark as Processing"
			case markEnroute	= "Mark as Enroute"
			case markDelivered	= "Mark as Delivered"
			case markReceived	= "Got It!"
			
			var isDestructive: Bool {
				self == .cancel
			}
			
			var message: String? {
				self == .cancel ? "Are you sure you want to cancel this order?" : nil
			}
			
			var id: Action { self }
			
			var status: Status {
				switch self {
				case .cancel:
					return .cancelled
				case .markProcessing:
					return .processed
				case .markEnroute:
					return .enroute
				case .markDelivered:
					return .delivered
				case .markReceived:
					return .completed
				}
			}
		}
		
		func nextAction(isRestaurant: Bool) -> Action? {
			switch self {
			case .placed:
				return isRestaurant ? .markProcessing : .cancel
			case .cancelled:
				return nil
			case .processed:
				return isRestaurant ? .markEnroute : nil
			case .enroute:
				return isRestaurant ? .markDelivered : nil
			case .delivered:
				return !isRestaurant ? .markReceived : nil
			case .completed:
				return nil
			}
		}
	}
	
	// display and identifying info
	var restaurantName: String
	var restaurantId: String
	var username: String
	var userFullName: String
	
	init(restaurant: Restaurant, diner: Diner, meals: [Meal] = []) {
		restaurantName = restaurant.name
		restaurantId = restaurant.id
		username = diner.username
		userFullName = "\(diner.firstName) \(diner.lastName)"
		self.meals = meals
	}
	
	var meals: [Meal] = []
	var orderId: String { String(id.split(separator: "-").last ?? "NA") }
	var id = UUID().uuidString
	var history: [Status: Date] = [:]
	
	var status: Status {
		history.sorted(by: {$0.value < $1.value}).last?.key ?? .cancelled
	}
	var datePlaced: Date { history[Status.placed] ?? Date(timeIntervalSince1970: 0) }
}

extension Array where Element == Order {
	var completed: [Order] {
		filter{$0.status == .cancelled || $0.status == .completed}.sorted(by: {$0.datePlaced < $1.datePlaced})
	}
	
	var open: [Order] {
		filter{$0.status != .completed && $0.status != .cancelled}.sorted(by: {$0.datePlaced < $1.datePlaced})
	}
}

//
func < (a: Order.Status, b: Order.Status) -> Bool {
	// cancelled is always last
	if a == .cancelled {
		return false
	}
	else if b == .cancelled {
		return true
	}
	
	if let aIndex = Order.Status.allCases.firstIndex(of: a),
	   let bIndex = Order.Status.allCases.firstIndex(of: b) {
		return aIndex < bIndex
	}
	
	return false
}

func > (a: Order.Status, b: Order.Status) -> Bool {
	// cancelled is always last
	!(a < b || a == b)
}
