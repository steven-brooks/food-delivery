//
//  LoginView.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 10/29/20.
//

import SwiftUI

struct LoginView: View {
	@ObservedObject var model: LoginViewModel
	
	@State var focus = [true, false]
	@State var showRegistration = false
	
	var ownerViewModel: OwnerViewModel?
	
    var body: some View {
		
		VStack {
			Image("logo")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.padding(.horizontal)
				.padding(.bottom, -32) // reduce the built-in padding
			
			Text("Food Delivery")
				.font(.system(size: 32, weight: .bold))
			
			TextFieldView(text: $model.username, focused: $focus[0], placeholder: "Username")
				.autocorrectionType(.no)
				.autocapitalizationType(.none)
				.tabOrder(1)
				.textBorder()
				
			TextFieldView(text: $model.password, focused: $focus[1], placeholder: "Password")
				.isSecureTextEntry(true)
				.autocorrectionType(.no)
				.autocapitalizationType(.none)
				.onReturn() { _ in
					focus = [false, false]
					model.login()
				}
				.tabOrder(2)
				.textBorder()
			
			Toggle(isOn: $model.rememberUsername) {
				Text("Remember Username:")
			}
			.toggleStyle(SwitchToggleStyle(tint: .toptalGreen))

			Button("Login") {
				focus = [false, false]
				model.login()
			}
			.buttonStyle(ToptalButtonStyle())
			
			HStack {
				Text("No Account?")

				NavigationLink(destination: TransitionView() ) {
				//Button(action: { showRegistration = true} ){
					Text("Register Here")
						.foregroundColor(.toptalBlue)
				}
			}
			.padding(.top)
			Spacer()
		}
		.onAppear() {
			if !model.username.isEmpty {
				focus = [false, true]
			}
		}
		.onDisappear() {
			//model.password = ""
		}
		.navigationBarHidden(true)
		.foregroundColor(.toptalDarkGrey)
		.padding()
		.activityIndicator(model.isServiceRunning)
		.alert(item: $model.errorMessage) {
			Alert(title: Text($0))
		}
		
		.fullScreenCover(isPresented: $model.validUser) {
			if let owner = model.owner {
				NavigationView {
					OwnerTransitionView(owner: owner)
				}
			}
			else if let diner = model.diner {
				NavigationView {
					DinerTransitionView(diner: diner)
				}
			}
		}
	}

	private struct TransitionView: View {
		var body: some View {
			RegisterView(model: RegisterViewModel())
		}
	}

	private struct DinerTransitionView: View {
		var diner: Diner
		
		var body: some View {
			DinerView(session: OrderSession(diner: diner))
		}
	}

	private struct OwnerTransitionView: View {
		var owner: Owner
		
		var body: some View {
			OwnerView(model: OwnerViewModel(owner: owner))
		}
	}
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
		NavigationView {
			LoginView(model: LoginViewModel())
		}
    }
}

struct ToptalButtonStyle: ButtonStyle {
	var color: Color = .toptalBlue
	
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(.system(size: 16, weight: .bold))
			.foregroundColor(.white)
			.frame(maxWidth: .infinity)
			.frame(height: 44)
			.background(color.cornerRadius(22))
			.opacity(configuration.isPressed ? 0.5 : 1)
	}
}

struct OutlineButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.foregroundColor(configuration.isPressed ? .white : .toptalBlue)
			.padding(.horizontal, 8)
			.background(RoundedRectangle(cornerRadius: 15)
							.stroke(lineWidth: 1)
							.frame(height: 30)
							.foregroundColor(configuration.isPressed ? .white : .toptalBlue))
			.background(Color.toptalBlue
							.cornerRadius(15)
							.frame(height: 30)
							.opacity(configuration.isPressed ? 1 : 0))
			.frame(height: 30)
	}
}
