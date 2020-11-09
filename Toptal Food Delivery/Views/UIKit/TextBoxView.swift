//
//  TextboxView.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 10/31/20.
//

import SwiftUI
import UIKit

struct TextBoxView: UIViewRepresentable {
	@Binding var text: String
	@Binding var focused: Bool
	
	func makeUIView(context: Context) -> UITextView {
		let view = UITextView()
		view.font = UIFont.systemFont(ofSize: 16)
		view.delegate = context.coordinator
		view.tintColor = UIColor(named: "toptalBlue")
		view.textColor = UIColor(named: "toptalDarkGrey")
		return view
	}
	
	func updateUIView(_ uiView: UITextView, context: Context) {
		uiView.text = text
		
		if focused {
			uiView.becomeFirstResponder()
		} else {
			uiView.resignFirstResponder()
		}
	}
	
	func makeCoordinator() -> Coordinator {
		return Coordinator(parent: self)
	}
	
	func textBorder() -> some View {
		self
			.padding(10)
			.overlay(RoundedRectangle(cornerRadius: 8)
						.inset(by: 1)
						.stroke(lineWidth: focused ? 1 : 0.5)
						.foregroundColor(.toptalDarkGrey))
	}
	
	class Coordinator: NSObject, UITextViewDelegate {
		let parent: TextBoxView
		
		init(parent: TextBoxView) {
			self.parent = parent
		}
		
		func textViewDidChange(_ textView: UITextView) {
			parent.text = textView.text
		}
		
		func textViewDidBeginEditing(_ textView: UITextView) {
			DispatchQueue.main.async { [unowned self] in
				parent.focused = true
			}
		}
		
		func textViewDidEndEditing(_ textView: UITextView) {
			DispatchQueue.main.async { [unowned self] in
				parent.focused = false
			}
		}
	}
}

struct TextEntryView_Previews: PreviewProvider {
	static var previews: some View {
		TextBoxView(text: .constant("TEXT"), focused: .constant(true))
			.previewLayout(.sizeThatFits).padding()
	}
}
