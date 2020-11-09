//
//  OrderView.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 11/6/20.
//

import SwiftUI

struct OrderView: View {
	var order: Order
	var showHeader = true
	var showStatus = true
	var isRestaurant: Bool
	
	var body: some View {
		VStack(alignment: .leading) {
			if showHeader {
				if showStatus {
					HStack {
						Text("Status: \(order.status.rawValue.capitalized)")
						Spacer()
						//Text(order.datePlaced, formatter: DateFormatter.shortFormatter)
					}
					.font(.footnote)
				}

				HStack(alignment: .bottom) {
					Text(isRestaurant ? order.userFullName : order.restaurantName)
						.font(.title2)

					Spacer()
					
					Text(order.datePlaced, formatter: DateFormatter.shortFormatter)
							.font(.footnote)
				}
				Divider()
			}

			ForEach(order.meals.unique, id: \.name) { meal in
				HStack {
					Text(meal.name)
					Spacer()
					Text("x \(order.meals.quantities[meal] ?? 0)")
					HStack {
						Spacer()
						Text("\(Float(order.meals.quantities[meal] ?? 0) * meal.price, specifier: "$%0.2f")")
					}
					.frame(width: 75)
				}
				.font(.footnote)
			}

			Divider()

			HStack {
				Text("Total:")
				Spacer()
				Text("\(order.meals.totalCost, specifier: "$%.02f")")
			}
		}
		.foregroundColor(.toptalDarkGrey)
	}
}

struct OrderView_Previews: PreviewProvider {
	static var previews: some View {
		let meals = [Meal(name: "Meal", description: "Meal", price: 5), Meal(name: "Meal 2", description: "Meal", price: 10)]
		let order = Order(restaurant: Restaurant(name: "Restaurant", description: "Description", owner: "Owner"),
						  diner: Diner(firstName: "Diner", lastName: "Smith", username: "diner", password: ""), meals: meals)

		OrderView(order: order, isRestaurant: true)
			.previewLayout(.sizeThatFits).padding()
		
		OrderView(order: order, showStatus: false, isRestaurant: false)
			.previewLayout(.sizeThatFits).padding()
		
		OrderView(order: order, showHeader: false, isRestaurant: false)
			.previewLayout(.sizeThatFits).padding()
	}
}
