//
//  UserView.swift
//  Food Delivery
//
//  Created by Steven Brooks on 11/2/20.
//

import SwiftUI
import Combine

struct DinerView: View {
	@Environment(\.presentationMode) var presentationMode
	@StateObject var session: OrderSession
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
				OrdersView(model: OrdersViewModel(diner: session.diner))
			}
			.navigationViewStyle(StackNavigationViewStyle())
				.tabItem {
					VStack {
						Image(systemName: "list.bullet")
						Text("Orders")
					}
				}
		}
		.accentColor(.appRed)
		.foregroundColor(.appDarkGray)
		.tabViewStyle(DefaultTabViewStyle())
		.navigationBarTitle(Text("Food Delivery"), displayMode: .inline)
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(leading: profileButton, trailing: cartButton)
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
				.foregroundColor(.appRed)
		}
	}
	
	var cartButton: some View {
		Button(action: { showCart.toggle() }) {
			Cart(order: $session.order)
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

private struct Cart: View {
	@State var cartAnimationProgress = 0.0
	@Binding var order: Order?
	
	var count: Int { order?.meals.count ?? 0 }
	@State var lastCount = 0
	
	var body: some View {
		ZStack {
			Image(systemName: "cart")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 30)
				.foregroundColor(.appRed)
				.overlay(Text("\(count)")
							.font(.system(size: 11, weight: .bold))
							.foregroundColor(.white)
							.background(Circle()
											.frame(width: 20, height: 20)
											.foregroundColor(.appGreen)
											.opacity(0.8))
							.opacity(count > 0 ? 1 : 0)
							.offset(x: 14, y: -12))
			
			//animated bubble
			Circle()
				.frame(width: 20, height: 20)
				.foregroundColor(.appGreen)
				.opacity(cartAnimationProgress / 2)
				.scaleEffect(CGFloat(2.5 - cartAnimationProgress * 1.5))
				.offset(x: 14, y: -12)
		}
		.onReceiveIf(order?.meals.publisher, perform: { _ in
			if order?.meals.count != lastCount {
				if order?.meals.count ?? 0 > lastCount {
					// only do the poof if something's being added
					cartAnimationProgress = 1
					withAnimation { cartAnimationProgress = 0 }
				}
				lastCount = order?.meals.count ?? 0
			}
		})
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
		let diner = Diner(firstName: "Joe", lastName: "Smith", email: "joe_smith")
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
