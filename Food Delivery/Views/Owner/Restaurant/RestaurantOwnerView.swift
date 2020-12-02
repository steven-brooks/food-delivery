//
//  RestaurantOwnerView.swift
//  Food Delivery
//
//  Created by Steven Brooks on 11/3/20.
//

import SwiftUI

struct RestaurantOwnerView: View {
	@StateObject var model: RestaurantOwnerViewModel
	@State var addingMeal = false
	@State var editingMeal: Meal?
	
	@State var focused = [false, false, false]
	@EnvironmentObject var ownerViewModel: OwnerViewModel
	@State var gotoOrders = false
		
    var body: some View {
		VStack(spacing: 0) {
			NavigationLink(destination: OrdersView(model: OrdersViewModel(restaurant: model.restaurant)), isActive: $gotoOrders) {}
			
			Button(action: { toggleEditing() }) {
				if !addingMeal {
					HStack {
						Image(systemName: "plus")
						Text("Add Meal")
					}
				} else {
					HStack {
						Image(systemName: "nosign")
						Text("Hide")
					}
				}
			}
			.buttonStyle(OutlineButtonStyle())
			.padding()
			
			if addingMeal {
				addMealView
			}
			
			List {
				ForEach(model.restaurant.meals, id: \.name) { meal in
					HStack {
						VStack(alignment: .leading) {
							Text(meal.name)
								.font(.title2)
							
							if !meal.description.isEmpty {
								Text(meal.description)
									.font(.subheadline)
									.multilineTextAlignment(.leading)
							}
						}
						
						Spacer()
						
						Text("\(meal.price, specifier: "$%.02f")")
							.font(.title2)
					}
					.contextMenu(ContextMenu(menuItems: {
						Button(action: { edit(meal) }) {
							Text("Edit")
						}
					}))
				}
				.onDelete() { indexSet in
					if let index = indexSet.first {
						model.mealToDelete = model.restaurant.meals[index]
					}
				}
			}
			.listStyle(InsetGroupedListStyle())
		}
		.activityIndicator(model.isServiceRunning)
		.navigationBarTitle(model.restaurant.name, displayMode: .inline)
		.navigationBarItems(trailing: ordersButton)
		// meal added
		.timedOverlay(item: $model.addedMeal, duration: 1) {
			resetForm()
		} _: { meal in
			SuccessOverlay(message: "\(meal.name) added!")
		}
		// meal updated
		.timedOverlay(item: $model.updatedMeal, duration: 1) {
			editingMeal = nil
			withAnimation { addingMeal = false }
		} _: { meal in
			SuccessOverlay(message: "\(meal.name) updated!")
		}
		// meal deleted
		.timedOverlay(item: $model.deletedMeal, duration: 1) { meal in
			SuccessOverlay(message: "\(meal.name) deleted!")
		}
		.alert(isPresented: $model.showAlert) {
			if let meal = model.mealToDelete {
				return deleteAlert(for: meal)
			}
			else {
				return Alert(title: Text(model.errorMessage ?? "Unknown Error"))
			}
		}
		.onDisappear() {
			// refresh the meals on the ownerViewModel
			if let index = ownerViewModel.owner.restaurants.firstIndex(where: {$0.id == model.restaurant.id}) {
				ownerViewModel.owner.restaurants[index].meals = model.restaurant.meals
			}
		}
	}
	
	var ordersButton: some View {
		//NavigationLink(destination: OrdersView(model: OrdersViewModel(restaurant: model.restaurant))) {
		Button(action: { gotoOrders = true }) {
			Text("Orders")
		}
	}
	
	var addMealView: some View {
		var tab = 0
		
		return VStack {
			HStack {
				TextFieldView(text: $model.mealToAddName, focused: $focused[tab], placeholder: "Name")
					.tabOrder(++tab)
					.textBorder()
					.padding(.trailing)
					
				Text("$")
				TextFieldView(text: $model.mealToAddPrice, focused: $focused[tab], placeholder: "Price")
					.tabOrder(++tab)
					.textBorder()
					.keyboardType(.decimalPad)
					.frame(maxWidth: 80)
			}
			
			TextFieldView(text: $model.mealToAddDescription, focused: $focused[tab], placeholder: "Description")
				.tabOrder(++tab)
				.textBorder()
			
			Button("Submit") {
				submit()
			}
			.buttonStyle(AppButtonStyle())
		}
		.padding(.horizontal)
		.foregroundColor(.appDarkGray)
	}
	
	private func resetForm() {
		model.mealToAddName = ""
		model.mealToAddDescription = ""
		model.mealToAddPrice = ""
		focused = [true, false, false]
	}

	func deleteAlert(for meal: Meal) -> Alert {
		Alert(title: Text("Are you sure you want to delete \(meal.name)?"), message: nil,
			  primaryButton: .cancel(),
			  secondaryButton: .destructive(Text("Delete")) {
				model.delete(meal: meal)
			  })
	}
	
	private func toggleEditing() {
		if !addingMeal {
			// select the first field
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
				focused[0] = true
			}
		} else {
			// clear the editing restaurant, if there is one
			editingMeal = nil
		}
		
		withAnimation {
			addingMeal.toggle()
		}
	}
	
	private func edit(_ meal: Meal) {
		model.mealToAddName = meal.name
		model.mealToAddDescription = meal.description
		model.mealToAddPrice = "\(meal.price)"

		editingMeal = meal
		withAnimation { addingMeal = true }
	}
	
	private func submit() {
		if editingMeal != nil {
			if (model.validateMealToEdit(meal: &editingMeal!)) {
				model.update(meal: editingMeal!)
			}
		}
		else if let meal = model.validateMealToAdd() {
			model.add(meal: meal)
		}
	}
}

struct OwnerOrdersView_Previews: PreviewProvider {
    static var previews: some View {
		NavigationView {
			RestaurantOwnerView(model: RestaurantOwnerViewModel(restaurant: Restaurant(name: "Restaurant", description: "Description", owner: "Owner", meals: [Meal(name: "Taco", description: "It's a taco", price: 2.98989)])))
		}
    }
}
