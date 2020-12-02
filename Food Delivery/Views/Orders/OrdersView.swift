//
//  OrdersView.swift
//  Food Delivery
//
//  Created by Steven Brooks on 11/5/20.
//

import SwiftUI

struct OrdersView: View {
	@StateObject var model: OrdersViewModel
	@State private var orderToUpdate: Order?
	
    var body: some View {
		ScrollView {
			VStack {
				if model.orders?.open.count ?? 0 > 0 {
					HStack {
						Text("Open Orders")
						Spacer()
					}
					
					section(orders: model.orders!.open)
				}
				
				if model.orders?.completed.count ?? 0 > 0 {
					HStack {
						Text("Completed Orders")
						Spacer()
					}
					.padding(.top)
					
					section(orders: model.orders!.completed)
				}
			}
			.padding()
			
		}
		.onAppear() {
			if let order = orderToUpdate {
				model.update(order: order)
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.activityIndicator(model.isServiceActive)
		.navigationBarTitle("Orders", displayMode: .inline)
		.navigationBarItems(trailing: Button(action: { model.getOrders() }) {
			Image(systemName: "arrow.counterclockwise")
				.foregroundColor(.appRed)
		})
	}
	
	func section(orders: [Order]) -> some View {
		ForEach(orders, id: \.orderId) { order in
			NavigationLink(destination: OrderStatusView(model: OrderStatusViewModel(order: order, restaurant: model.restaurant).onOrderUpdated {
				// save the order if the status was changed
				// so that we can update it later
				orderToUpdate = $0
			})) {
				OrderView(order: order, isRestaurant: model.isRestaurant)
					.padding()
					.background(RoundedRectangle(cornerRadius: 8)
									.stroke(lineWidth: 1)
									.foregroundColor(.appRed))
			}
		}
	}
}

struct OrdersView_Previews: PreviewProvider {
	
	static var model: OrdersViewModel {
		let restaurant = Restaurant(name: "Restaurant", description: "Description", owner: "Owner")
		let diner = Diner(firstName: "Diner", lastName: "McGee", email: "username")
		let orders = OrdersViewModel(diner: diner)
		let meals = [Meal(name: "Meal", description: "Meal", price: 5), Meal(name: "Meal 2", description: "Meal", price: 10)]
		orders.orders = [Order(restaurant: restaurant, diner: diner, meals: meals),
						 Order(restaurant: restaurant, diner: diner, meals: meals)]
		return orders
	}
	
    static var previews: some View {
		NavigationView {
			OrdersView(model: OrdersView_Previews.model)
		}
    }
}
