//
//  ActivityIndicatorView.swift
//  Food Delivery
//
//  Created by Steven Brooks on 10/31/20.
//

import SwiftUI
import UIKit

struct ActivityIndicator: UIViewRepresentable {
	var style: UIActivityIndicatorView.Style
	
	func makeUIView(context: Context) -> UIActivityIndicatorView {
		let view = UIActivityIndicatorView(style: style)
		view.color = .white
		view.startAnimating()
		return view
	}
	
	func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
	}
}

struct ActivityIndicatorView_Previews: PreviewProvider {
	static var previews: some View {
		ActivityIndicator(style: .large)
	}
}
