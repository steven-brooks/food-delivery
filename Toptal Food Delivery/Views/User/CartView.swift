//
//  CartView.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 11/4/20.
//

import SwiftUI

struct CartView: View {
	@StateObject var session: OrderSession
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		NavigationView {
			if (session.order?.meals ?? []).isEmpty {
				emptyCartView
			} else {
				orderView
			}
		}
	}
	
	var orderView: some View {
		VStack {
			List {
				ForEach(session.order!.meals.unique, id: \.name) { meal in
					HStack {
						Text(meal.name)
						Spacer()
						quantityView(for: meal)
						HStack {
							Spacer()
							priceView(for: meal)
						}
						.frame(width: 75)
					}
					.buttonStyle(PlainButtonStyle())
				}
				
				HStack {
					Text("Total:")
					Spacer()
					Text("\(session.order!.meals.totalCost, specifier: "$%.02f")")
				}
			}
			.listStyle(InsetGroupedListStyle())
			
			Spacer()
			
			Button("Submit") {
				session.submitOrder()
			}
			.buttonStyle(ToptalButtonStyle())
			.padding()
		}
		.navigationBarTitle(session.order?.restaurantName ?? "N/A")
		.activityIndicator(session.isSubmittingOrder)
		.timedOverlay(item: $session.submittedOrder, duration: 1) {
			presentationMode.wrappedValue.dismiss()
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
				session.order = nil
			}
		} _: { (order) in
			SuccessOverlay(message: "Order submitted!")
		}
		.alert(isPresented: $session.showCartAlert) {
			if let meal = session.deleteMealConfirmation {
				return deleteAlert(for: meal)
			}
			else { // cartErrorMessage
				return Alert(title: Text(session.cartErrorMessage ?? "Unkown Error"))
			}
		}
    }
	
	var emptyCartView: some View {
		Text("You haven't added anything!")
			.multilineTextAlignment(.center)
	}
	
	func quantityView(for meal: Meal) -> some View {
		HStack {
			Button(action: {
				if session.order!.meals.quantities[meal] ?? 0 > 1 {
					session.decrement(meal: meal)
				} else {
					session.deleteMealConfirmation = meal
				}
			}) {
				ZStack {
					Color.gray.cornerRadius(8)
					Image(systemName: "minus")
						.foregroundColor(.white)
				}
			}
			.frame(width: 30)
			
			Text("\(session.order!.meals.quantities[meal] ?? 0)")
				.bold()
				.frame(width: 24)
			
			Button(action: { session.increment(meal: meal) }) {
				ZStack {
					Color.gray.cornerRadius(8)
					Image(systemName: "plus")
						.foregroundColor(.white)
				}
			}
			.frame(width: 30)
		}
		.frame(height: 30)
	}
	
	func priceView(for meal: Meal) -> some View {
		Text("\(meal.price * Float(session.order!.meals.quantities[meal] ?? 0), specifier: "$%.02f")")
	}
	
	func deleteAlert(for meal: Meal) -> Alert {
		Alert(title: Text("Are you sure you want to remove \(meal.name)?"), message: nil,
			  primaryButton: .cancel(),
			  secondaryButton: .destructive(Text("Remove")) {
				session.decrement(meal: meal)
			  })
	}
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
		CartView(session: UserView_Previews.session)
    }
}
