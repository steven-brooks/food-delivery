//
//  RegisterView.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 10/29/20.
//

import SwiftUI

struct RegisterView: View {
	@ObservedObject var model: RegisterViewModel
	
	// first name, last name, username, password, password confirm
	@State var focused: [Bool] = [true, false, false, false, false]
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		var tab = 0
		
		return VStack {
			Image("logo")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(maxHeight: 64)
			
			HStack {
				TextFieldView(text: $model.firstName, focused: $focused[tab], placeholder: "First Name")
					.tabOrder(++tab)
					.autocorrectionType(.no)
					.textBorder()

				TextFieldView(text: $model.lastName, focused: $focused[tab], placeholder: "Last Name")
					.tabOrder(++tab)
					.autocorrectionType(.no)
					.textBorder()
			}
			TextFieldView(text: $model.username, focused: $focused[tab], placeholder: "Username")
				.tabOrder(++tab)
				.autocorrectionType(.no)
				.autocapitalizationType(.none)
				.textBorder()

			TextFieldView(text: $model.password, focused: $focused[tab], placeholder: "Password")
				.tabOrder(++tab)
				.isSecureTextEntry(true)
				.textBorder()
			
			TextFieldView(text: $model.confirmPassword, focused: $focused[tab], placeholder: "Confirm Password")
				.tabOrder(++tab)
				.isSecureTextEntry(true)
				.textBorder()
			
			HStack {
				Text("Register as:")
				Picker("", selection: $model.userType) {
					ForEach(RegisterViewModel.UserType.allCases, id: \.self) {
						Text($0.rawValue.capitalized)
					}
				}
				.pickerStyle(SegmentedPickerStyle())
			}
			.padding(.vertical)
			
			Button("Register") {
				if model.validate() {
					model.register()
				}
			}
			.buttonStyle(ToptalButtonStyle())
			
			Spacer()
		}
		.navigationBarTitle("New Account", displayMode: .inline)
		.navigationBarHidden(false)
		.foregroundColor(.toptalDarkGrey)
		.padding()
		.activityIndicator(model.isServiceRunning)
		.alert(item: $model.errorMessage) {
			Alert(title: Text($0))
		}
		.timedOverlay(item: $model.diner, duration: 1) {
			presentationMode.wrappedValue.dismiss()
		} _: { _ in
			SuccessOverlay(message: "Registration successful!\nYou can now log in.")
		}
		.timedOverlay(item: $model.owner, duration: 1) {
			presentationMode.wrappedValue.dismiss()
		} _: { _ in
			SuccessOverlay(message: "Registration successful!\nYou can now log in.")
		}
	}
}

struct RegisterView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			RegisterView(model: RegisterViewModel())
		}
	}
}
