//
//  OrderStatusView.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 11/6/20.
//

import SwiftUI

struct OrderStatusView: View {
	@StateObject var model: OrderStatusViewModel
	@Environment(\.presentationMode) var presentationMode
	
	var onOrderUpdated: (() -> ())? = nil
	
    var body: some View {
		VStack {
			VStack {
				if model.isRestaurant {
					nameButton
					
					Divider()
						.padding(.horizontal)
				}
				
				OrderView(order: model.order, showHeader: !model.isRestaurant, showStatus: false, isRestaurant: model.isRestaurant)
					.padding()
				
				ZStack {
					StatusDial(status: model.order.status)
					Text("\((model.order.status).rawValue.capitalized)")
						.font(.title)
						.offset(y: 75)
				}
				
				if let action = model.order.status.nextAction(isRestaurant: model.isRestaurant) {
					Button(action.rawValue) {
						model.performAction()
					}
					.buttonStyle(ToptalButtonStyle())
					.padding()
				}
			}.padding(.horizontal)
			Spacer()
			List {
				Section(header: Text("History")) {
					ForEach(model.order.history.sorted(by: {$0.key < $1.key}), id: \.key) { key, value in
						HStack {
							Text(key.rawValue.capitalized)
							Spacer()
							Text("\(value, formatter: DateFormatter.shortFormatter)")
						}
					}
				}
			}
			.listStyle(InsetGroupedListStyle())
		}
		.navigationBarTitle("Order ID: \(model.order.orderId)", displayMode: .inline)
		.alert(isPresented: $model.showAlert) {
			if let action = model.confirmationAlert {
				return actionAlert(for: action)
			}
			else if model.blockUserAlert {
				return blockUserAlert
			}
			else { // errorMessage
				return Alert(title: Text(model.errorMessage ?? "N/A"))
			}
		}
		.timedOverlay(item: $model.successMessage, duration: 1) {
			if model.dismissOnChange {
				presentationMode.wrappedValue.dismiss()
			}
		} _: {
			SuccessOverlay(message: $0)
		}
		.timedOverlay(item: $model.userBlockedSuccess, duration: 1) {
			SuccessOverlay(message: $0)
		}
    }
	
	func onOrderUpdated(_ block: @escaping (() -> ())) -> Self {
		var view = self
		view.onOrderUpdated = block
		return view
	}
	
	func actionAlert(for action: Order.Status.Action) -> Alert {
		Alert(title: Text(action.message ?? "N/A"), message: nil,
			  primaryButton: .cancel(Text("NO")),
			  secondaryButton: .destructive(Text("Yes")) {
				model.performConfirmationAction()
			  })
	}
	
	var blockUserAlert: Alert {
		let title = model.restaurant?.blockedUsers.contains(model.order.username) ?? false ?
			"Do you want to unblock \(model.order.userFullName)?" :
			"Do you want to block \(model.order.userFullName)?"
		
		return Alert(title: Text(title), message: nil,
			  primaryButton: .cancel(Text("NO")),
			  secondaryButton: .destructive(Text("Yes")) {
				model.toggleUserBlocked()
			  })
	}
	
	// allow owners to block users from restaurants
	var nameButton: some View {
		Button(action: {model.blockUserAlert = true}) {
			HStack {
				Text(model.order.userFullName)
					.font(.title2)
					.foregroundColor(.toptalDarkGrey)
				
				Circle()
					.foregroundColor(model.restaurant?.blockedUsers.contains(model.order.username) ?? false ? .red : .toptalGreen)
					.frame(width: 20, height: 20)
			}
		}
		.buttonStyle(OutlineButtonStyle())
		.padding(.top)
	}
}

struct OrderStatusView_Previews: PreviewProvider {
    static var previews: some View {
		let restaurant = Restaurant(name: "Restaurant", description: "Description", owner: "Owner")
		let diner = Diner(firstName: "Diner", lastName: "Smith", username: "diner", password: "")
		let meals = [Meal(name: "Meal", description: "Meal", price: 5), Meal(name: "Meal 2", description: "Meal", price: 10)]
		var order = Order(restaurant: restaurant, diner: diner, meals: meals)
		
		let start: TimeInterval = -60 * 60 * 24 * 7
		order.history = [.placed: Date(timeIntervalSinceNow: start),
						 .processed: Date(timeIntervalSinceNow: start + (60 * 3)),
						 .enroute: Date(timeIntervalSinceNow: start + (60 * 19))]
		
		return NavigationView {
			OrderStatusView(model: OrderStatusViewModel(order: order, restaurant: restaurant))
		}
    }
}
