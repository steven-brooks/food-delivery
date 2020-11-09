//
//  UserView.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 11/2/20.
//

import SwiftUI
import Combine

struct DinerView: View {
	@Environment(\.presentationMode) var presentationMode
	@ObservedObject var session: OrderSession
	@State var showLogoutAlert = false
	@State var showCart = false
	
	let restaurantsViewModel = RestaurantsViewModel()

	var body: some View {
		TabView {
			NavigationView {
				RestaurantsView(model: restaurantsViewModel, session: session)
			}
			.navigationViewStyle(StackNavigationViewStyle())
				.tabItem {
					VStack {
						Image(systemName: "book.fill")
						Text("Food")
					}
				}
			
			NavigationView {
				OwnerTransitionView(diner: session.diner)
			}
			.navigationViewStyle(StackNavigationViewStyle())
				.tabItem {
					VStack {
						Image(systemName: "list.bullet")
						Text("Orders")
					}
				}
		}
		.accentColor(.toptalBlue)
		.foregroundColor(.toptalDarkGrey)
		.tabViewStyle(DefaultTabViewStyle())
		.navigationBarTitle(Text("Toptal Food"), displayMode: .inline)
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(leading: profileButton, trailing: cartButton)
		//.alert(isPresented: $showLogoutAlert) { logoutAlert }
		//.alert(isPresented: $session.orderStartedFromDifferentRestaurant) { multipleRestaurantsAlert }
		.alert(isPresented: $session.showAlert) {
			if session.orderStartedFromDifferentRestaurant {
				return multipleRestaurantsAlert
			}
			else if session.showLogoutAlert {
				return logoutAlert
			}
			else { // errorMessage
				return Alert(title: Text(session.errorMessage ?? "Unkown Error"))
			}
		}
		.sheet(isPresented: $showCart) { CartView(session: session) }
	}
	
	@State var showProfileMenu = true
	
	var profileButton: some View {
		Button(action: { session.showLogoutAlert = true }) {
			Image(systemName: "person.crop.circle")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 30)
				.foregroundColor(.toptalBlue)
		}
	}
	
	var cartButton: some View {
		Button(action: { showCart.toggle() }) {
			Image(systemName: "cart")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 30)
				.foregroundColor(.toptalBlue)
				.onReceiveIf(session.order?.meals.publisher) { _ in
					// do some animation
				}
				.overlay(Text("\(session.order?.meals.count ?? 0)")
							.font(.system(size: 11, weight: .bold))
							.foregroundColor(.white)
							.background(Circle()
											.frame(width: 20, height: 20)
											.foregroundColor(.toptalGreen)
											.opacity(0.8))
							.opacity(session.order?.meals.count ?? 0 > 0 ? 1 : 0)
							.offset(x: 14, y: -12))
		}
	}
	
	var logoutAlert: Alert {
		Alert(title: Text("Logout"), message: Text("Are you sure you would like to logout?"),
			  primaryButton: .cancel(),
			  secondaryButton: .destructive(Text("Logout")) {
				presentationMode.wrappedValue.dismiss()
			  })
	}
	
	var multipleRestaurantsAlert: Alert {
		Alert(title: Text("Warning"), message: Text("You have already started an order from a different restaurant. Would you like to empty your cart?"),
			  primaryButton: .cancel(),
			  secondaryButton: .destructive(Text("Empty Cart")) {
				session.order = nil
			  })
	}
}

private struct OwnerTransitionView: View {
	var diner: Diner
	
	var body: some View {
		OrdersView(model: OrdersViewModel(diner: diner))
	}
}

extension View {
	@inlinable public func onReceiveIf<P>(_ publisher: P?, perform action: @escaping (P.Output) -> Void) -> some View where P : Publisher, P.Failure == Never {
		if let publisher = publisher {
			return self.onReceive(publisher, perform: action).eraseToAnyView()
		} else {
			return self.eraseToAnyView()
		}
	}
}

struct UserView_Previews: PreviewProvider {
	static var session: OrderSession {
		let restaurant = Restaurant(name: "Restaurant", description: "Description", owner: "Owner")
		let diner = Diner(firstName: "Joe", lastName: "Smith", username: "joe_smith", password: "")
		let session = OrderSession(diner: diner)
		session.order = Order(restaurant: restaurant,
							  diner: diner,
							  meals: [
								Meal(name: "Meal 1", description: "The First Meal", price: 5),
								Meal(name: "Meal 1", description: "The First Meal", price: 5),
								Meal(name: "Meal 2 has a longer name", description: "The Second Meal", price: 10),
							  ])
		return session
	}
	
	static var previews: some View {
		NavigationView {
			DinerView(session: UserView_Previews.session)
		}
	}
}
