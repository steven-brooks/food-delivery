//
//  RegisterView.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 10/29/20.
//

import SwiftUI

struct RegisterView: View {
	@ObservedObject var model: RegisterViewModel
	
	// first name, last name, username, password
	@State var focused: [Bool] = [true, false, false, false]
	
	var body: some View {
		var tab = 0
		
		return VStack {
			Image("logo")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(maxHeight: 64)
			
			HStack {
//				TextField("First Name", text: $model.firstName)
//					.textFieldStyle(RoundedBorderTextFieldStyle())
//
//				TextField("Last Name", text: $model.lastName)
//					.textFieldStyle(RoundedBorderTextFieldStyle())
				
				TextFieldView(text: $model.firstName, focused: $focused[tab], placeholder: "First Name")
					.tabOrder(++tab)
					.autocorrectionType(.no)
					.textBorder()

				TextFieldView(text: $model.lastName, focused: $focused[tab], placeholder: "Last Name")
					.tabOrder(++tab)
					.autocorrectionType(.no)
					.textBorder()
			}
//			TextField("Username", text: $model.username)
//				.textFieldStyle(RoundedBorderTextFieldStyle())
//
//			TextField("Password", text: $model.password)
//				.textFieldStyle(RoundedBorderTextFieldStyle())
			
			TextFieldView(text: $model.username, focused: $focused[tab], placeholder: "Username")
				.tabOrder(++tab)
				.textBorder()

			TextFieldView(text: $model.password, focused: $focused[tab], placeholder: "Password")
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
	}
}

struct RegisterView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			RegisterView(model: RegisterViewModel())
		}
	}
}
