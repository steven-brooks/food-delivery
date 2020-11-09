//
//  RestaurantView.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 11/4/20.
//

import SwiftUI

struct RestaurantView: View {
	@ObservedObject var model: RestaurantViewModel
	@EnvironmentObject var session: OrderSession
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		ScrollView {
			ForEach(model.restaurant.meals.sorted(by: {$0.name < $1.name}), id: \.name) { meal in
				HStack {
					VStack(alignment: .leading) {
						Text(meal.name)
							.font(.title2)
						
						if !meal.description.isEmpty {
							Text(meal.description)
								.font(.subheadline)
						}
					}
					
					Spacer()
					
					Text("\(meal.price, specifier: "$%.02f")")
						.font(.title2)
					
					// add to cart
					Button(action: { session.add(meal: meal, from: model.restaurant) }) {
						Image(systemName: "plus.circle.fill")
							.resizable()
							.foregroundColor(.toptalGreen)
							.frame(width: 30, height: 30)
					}
				}
				Divider()
			}
		}
		.padding()
		.onAppear() {
			model.fetchMeals()
		}
		.navigationBarTitle(model.restaurant.name, displayMode: .inline)
		.onReceive(session.submittedOrder.publisher, perform: { value in
			presentationMode.wrappedValue.dismiss()
		})
    }
}

struct RestaurantView_Previews: PreviewProvider {
    static var previews: some View {
		NavigationView {
			RestaurantView(model: RestaurantViewModel(restaurant: Restaurant(name: "Restaurant", description: "", owner: "Owner", meals: [
				Meal(name: "Meal 1", description: "Meal 1 Description", price: 5),
				Meal(name: "Meal 2", description: "Meal 2 Description", price: 10),
				Meal(name: "Meal 3", description: "Meal 3 Description", price: 15)
			])))
		}
    }
}
