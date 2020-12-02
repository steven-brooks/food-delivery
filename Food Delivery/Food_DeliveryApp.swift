//
//  Food_DeliveryApp.swift
//  Food Delivery
//
//  Created by Steven Brooks on 10/29/20.
//

import SwiftUI
import Combine
import Firebase

@main
struct Food_DeliveryApp: App {
	init() {
		FirebaseApp.configure()
		
		UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(named: "appGreen")
		UINavigationBar.appearance().tintColor = UIColor(named: "appRed")
	}
	
	var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
