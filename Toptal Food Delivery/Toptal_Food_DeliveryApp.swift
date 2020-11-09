//
//  Toptal_Food_DeliveryApp.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 10/29/20.
//

import SwiftUI
import Combine

@main
struct Toptal_Food_DeliveryApp: App {
	init() {
		UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(named: "toptalGreen")
		UINavigationBar.appearance().tintColor = UIColor(named: "toptalBlue")
	}
	
	var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
