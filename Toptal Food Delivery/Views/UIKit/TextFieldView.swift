//
//  TextFieldView.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 10/31/20.
//

import SwiftUI
import UIKit

struct TextFieldView : UIViewRepresentable {
	
	@Binding var text : String
	@Binding var focused : Bool
	
	var placeholder : String?
	var isSecureTextEntry = false
	var textContentType : UITextContentType?
	var returnKeyType : UIReturnKeyType?
	var keyboardType : UIKeyboardType?
	var autocorrectionType : UITextAutocorrectionType?
	var autocapitalizationType : UITextAutocapitalizationType?
	var tabOrder: Int?
	
	var focusChangedHandler : ((Bool)->())?
	var endEditingHandler : ((String?)->())?
	var returnHandler : ((String?)->())?
	var valueChangedHandler : ((String?)->())?

	func makeUIView(context: Context) -> UITextField {
		let view = UITextField()
		view.font = UIFont.systemFont(ofSize: 16)
		view.setContentHuggingPriority(.required, for: .vertical)
		view.delegate = context.coordinator
		view.addTarget(context.coordinator, action: #selector(TextFieldView.Coordinator.textFieldDidChange), for: .editingChanged)
		view.textColor = UIColor(named: "toptalDarkGrey")
		view.tintColor = UIColor(named: "totalBlue")
		view.clearButtonMode = .whileEditing
		return view
	}

	func updateUIView(_ textField: UITextField, context: Context) {
		textField.placeholder = placeholder
		if let returnKey = returnKeyType {
			textField.returnKeyType = returnKey
		}
		
		if let keyboardType = keyboardType {
			textField.keyboardType = keyboardType
		}
		
		if let autocorrect = autocorrectionType {
			textField.autocorrectionType = autocorrect
		}
		
		if let autocapitalization = autocapitalizationType {
			textField.autocapitalizationType = autocapitalization
		}
		if let type = textContentType {
			textField.textContentType = type
		}
		
		textField.tag = tabOrder ?? -1
		var text = self.text
		if isSecureTextEntry != textField.isSecureTextEntry {
			// maintain the entered text when toggling secure text entry
			text = textField.text ?? ""
			DispatchQueue.main.async {
				self.$text.wrappedValue = text
			}
		}
		textField.isSecureTextEntry = isSecureTextEntry
		textField.text = text
		
		if focused {
			textField.becomeFirstResponder()
		}
		else {
			textField.resignFirstResponder()
		}
	}
	
	func textBorder() -> some View {
		self
			.padding(10)
			.overlay(RoundedRectangle(cornerRadius: 8)
						.inset(by: 1)
						.stroke(lineWidth: focused ? 1 : 0.5)
						.foregroundColor(.toptalDarkGrey))
	}
		
	func onFocusChanged(_ handler: @escaping (Bool) -> ()) -> Self {
		var view = self
		view.focusChangedHandler = handler
		return view
	}
	
	func onEndEditing(_ handler: @escaping (String?)->()) -> Self {
		var view = self
		view.endEditingHandler = handler
		return view
	}
	
	func onReturn(_ handler: @escaping (String?)->()) -> Self {
		var view = self
		view.returnHandler = handler
		return view
	}
	
	func onValueChanged(_ handler: @escaping (String?)->()) -> Self {
		var view = self
		view.valueChangedHandler = handler
		return view
	}
	
	func tabOrder(_ value: Int?) -> Self {
		var view = self
		view.tabOrder = value
		return view
	}
	
	func isSecureTextEntry(_ value: Bool) -> Self {
		var view = self
		view.isSecureTextEntry = value
		return view
	}
	
	func textContentType(_ value: UITextContentType?) -> Self {
		var view = self
		view.textContentType = value
		return view
	}
	
	func returnKeyType(_ value: UIReturnKeyType?) -> Self {
		var view = self
		view.returnKeyType = value
		return view
	}
	
	func keyboardType(_ value: UIKeyboardType?) -> Self {
		var view = self
		view.keyboardType = value
		return view
	}
	
	func autocorrectionType(_ value: UITextAutocorrectionType) -> Self {
		var view = self
		view.autocorrectionType = value
		return view
	}
	
	func autocapitalizationType(_ value: UITextAutocapitalizationType) -> Self {
		var view = self
		view.autocapitalizationType = value
		return view
	}
}

// MARK: - Coordinator
extension TextFieldView {
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	class Coordinator: NSObject, UITextFieldDelegate {
		var parent: TextFieldView
		
		init(_ textField: TextFieldView) {
			 self.parent = textField
		 }
				
		func textFieldDidBeginEditing(_ textField: UITextField) {
			DispatchQueue.main.async {
				self.parent.focused = true
				self.parent.focusChangedHandler?(true)
			}
		}
	   
		@objc func textFieldDidChange(_ textField: UITextField) {
			parent.text = textField.text ?? ""
			parent.valueChangedHandler?(textField.text)
		}
				
		func textFieldDidEndEditing(_ textField: UITextField) {
			DispatchQueue.main.async {
				self.parent.text = textField.text ?? ""
				self.parent.focused = false
				self.parent.focusChangedHandler?(false)
				self.parent.endEditingHandler?(textField.text)
			}
		}
		
		func textFieldShouldReturn(_ textField: UITextField) -> Bool {
			var superview = textField.superview
			while superview?.superview != nil {
				superview = superview?.superview
			}
			
			if let tab = parent.tabOrder, let nextField = superview?.viewWithTag(tab + 1) {
				nextField.becomeFirstResponder()
			}
			else {
				textField.resignFirstResponder()
			}
			
			parent.returnHandler?(textField.text)
				
			return true
		}
	}
}

