//
//  OwnerView.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 10/30/20.
//

import SwiftUI

struct OwnerView: View {
	@ObservedObject var model: OwnerViewModel
	@State var addingRestaurant = false
	@State var focused = [false, false]
	@State var editingRestaurant: Restaurant?
	
	@Environment(\.presentationMode) var presentationMode

	var body: some View {
		
		VStack(spacing: 0) {
			Button(action: { toggleEditing() }) {
				if addingRestaurant {
					HStack {
						Image(systemName: "nosign")
						Text("Hide")
					}
				} else {
					HStack {
						Image(systemName: "plus")
						Text("Add Restaurant")
					}
				}
			}
			.buttonStyle(OutlineButtonStyle())
			.padding()
			
			if addingRestaurant {
				addRestaurantView
			}
			
			List {
				ForEach(model.owner.restaurants, id: \.name) { restaurant in
					NavigationLink(destination: MealTransitionView(restaurant: restaurant).environmentObject(model)) {
						Text(restaurant.name)
					}
					.contextMenu(ContextMenu(menuItems: {
						Button(action: {
							edit(restaurant)
						}) {
							Text("Edit")
						}
					}))
					.foregroundColor(.toptalDarkGrey)
				}
				.onDelete() { indexSet in
					if let index = indexSet.first {
						model.restaurantToDelete = model.owner.restaurants[index]
					}
				}
			}
			.listStyle(InsetGroupedListStyle())
		}
	
		.frame(maxWidth: .infinity)
		.navigationBarTitle(model.owner.name, displayMode: .inline)
		.navigationBarHidden(false)
		.navigationBarItems(leading: logoutButton)
		// restaurant added
		.timedOverlay(item: $model.addedRestaurant, duration: 1) {
			resetForm()
		} _: { restaurant in
			SuccessOverlay(message: "\(restaurant.name) added!")
		}
		// restaurant deleted
		.timedOverlay(item: $model.deletedRestaurant, duration: 1) { restaurant in
			SuccessOverlay(message: "\(restaurant.name) deleted!")
		}
		// restaurant updated
		.timedOverlay(item: $model.updatedRestaurant, duration: 1) {
			editingRestaurant = nil
			withAnimation { addingRestaurant = false }
		} _: { restaurant in
			SuccessOverlay(message: "\(restaurant.name) updated!")
		}
		.alert(isPresented: $model.showAlert) {
			if let message = model.errorMessage {
				return Alert(title: Text(message))
			}
			else if let restaurant = model.restaurantToDelete {
				return deleteAlert(for: restaurant)
			}
			else { //showLogoutAlert
				return logoutAlert
			}
		}
	}
	
	private var addRestaurantView: some View {
		VStack(alignment: .leading) {
			TextFieldView(text: $model.restaurantToAddName, focused: $focused[0], placeholder: "Name")
				.onReturn() { _ in focused[1] = true }
				.textBorder()
						
			Text("Description:")
				.font(.footnote)
			TextBoxView(text: $model.restaurantToAddDescription, focused: $focused[1])
				.textBorder()
				.frame(height: 128)
			
			Button("Submit") {
				submit()
			}
			.buttonStyle(ToptalButtonStyle())
		}
		.padding([.horizontal, .bottom])
	}
	
	private var logoutButton: some View {
		Button(action: { model.showLogoutAlert = true }) {
			Text("Logout")
		}
	}
	
	var logoutAlert: Alert {
		Alert(title: Text("Logout"), message: Text("Are you sure you would like to logout?"),
			  primaryButton: .cancel(),
			  secondaryButton: .destructive(Text("Logout")) {
				presentationMode.wrappedValue.dismiss()
			  })
	}
	
	func deleteAlert(for restaurant: Restaurant) -> Alert {
		Alert(title: Text("Are you sure you want to delete \(restaurant.name)?"), message: nil,
			  primaryButton: .cancel(),
			  secondaryButton: .destructive(Text("Delete")) {
				model.delete(restaurant: restaurant)
			  })
	}
	
	private func toggleEditing() {
		if !addingRestaurant {
			// select the first field
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
				focused[0] = true
			}
		} else {
			// clear the editing restaurant, if there is one
			editingRestaurant = nil
		}
		
		withAnimation {
			addingRestaurant.toggle()
		}
	}
	
	private func edit(_ restaurant: Restaurant) {
		model.restaurantToAddName = restaurant.name
		model.restaurantToAddDescription = restaurant.description

		editingRestaurant = restaurant
		withAnimation { addingRestaurant = true }
	}
	
	private func submit() {
		if editingRestaurant != nil {
			if (model.validateRestaurantToEdit(restaurant: &editingRestaurant!)) {
				model.update(restaurant: editingRestaurant!)
			}
		}
		else if let restaurant = model.validateRestaurantToAdd() {
			model.add(restaurant: restaurant)
		}
	}
	
	private func resetForm() {
		model.restaurantToAddName = ""
		model.restaurantToAddDescription = ""
		focused[1] = false
		focused[0] = true
	}
}

private struct MealTransitionView: View {
	var restaurant: Restaurant
	
	var body: some View {
		RestaurantOwnerView(model: RestaurantOwnerViewModel(restaurant: restaurant))
	}
}

struct OwnerView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			OwnerView(model: OwnerViewModel(owner: Owner(firstName: "Restaurant", lastName: "Owner", username: "owner", password: "********", restaurants: [
				Restaurant(name: "Restaurant 1", description: "This is the first one", owner: "Owner", meals: []),
				Restaurant(name: "Restaurant 2", description: "This is the second one", owner: "Owner", meals: []),
				Restaurant(name: "Restaurant 3", description: "This is the third one", owner: "Owner", meals: []),
				Restaurant(name: "Restaurant 4", description: "This is the fourth one", owner: "Owner", meals: []),
			])))
		}
		
		NavigationView {
			OwnerView(model: OwnerViewModel(owner: Owner(firstName: "Restaurant", lastName: "Owner", username: "owner", password: "********")))
		}
	}
}
