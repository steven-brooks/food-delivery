//
//  ContentView.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 10/29/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
		NavigationView {
			LoginView(model: LoginViewModel())
		}
		.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
