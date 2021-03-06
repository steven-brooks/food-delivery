//
//  RestaurantsView.swift
//  Food Delivery
//
//  Created by Steven Brooks on 11/2/20.
//

import SwiftUI

struct RestaurantsView: View {
	@StateObject var model: RestaurantsViewModel
	var session: OrderSession
	
	@State var choice: Restaurant?
	@State var linkActive = false
	
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		List {
			ForEach(model.availableRestaurants(for: session.diner), id: \.name) { restaurant in
				NavigationLink(destination: RestaurantView(model: RestaurantViewModel(restaurant: restaurant)).environmentObject(session)) {
					VStack(alignment: .leading) {
						Text(restaurant.name)
							.font(.title2)
						Text(restaurant.description)
							.font(.subheadline)
					}
				}
			}
		}
		.foregroundColor(.appDarkGray)
		.navigationBarTitle("Restaurants")
		.background(Color.appDarkGray.edgesIgnoringSafeArea(.all))
		.activityIndicator(model.isServiceActive, message: "Fetching Restaurants...")
	}
}



struct RestaurantsView_Previews: PreviewProvider {
	static var previews: some View {
		RestaurantsView(model: RestaurantsViewModel(restaurants: [
			Restaurant(name: "Restaurant 1", description: "This is the first one", owner: "Owner"),
			Restaurant(name: "Restaurant 2", description: "This is the second one", owner: "Owner"),
			Restaurant(name: "Restaurant 3", description: "This is the third one", owner: "Owner"),
			Restaurant(name: "Restaurant 4", description: "This is the fourth one", owner: "Owner")
		]), session: UserView_Previews.session)
	}
}
