//
//  ViewExtensions.swift
//  Toptal Food Delivery
//
//  Created by Steven Brooks on 10/31/20.
//

import SwiftUI

extension View {
	public func activityIndicator(_ visible: Bool, message: String? = nil) -> some View {
		self.overlay(
		ZStack {
			Color.black
				.opacity(0.5)
				.edgesIgnoringSafeArea(.all)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			
			VStack {
				ActivityIndicator(style: .large)
				
				if let message = message {
					Text(message)
						.bold()
						.foregroundColor(.white)
				}
			}
		}
		.frame(maxWidth: .infinity)
		.animation(.none)
		.opacity(visible ? 1 : 0)
		.animation(.easeInOut))
	}
	
	public func fadingOverlay<Overlay: View>(_ condition: Bool, _ overlay: @escaping () -> (Overlay)) -> some View {
		self.overlay(overlay().opacity(condition ? 1 : 0).animation(.easeIn))
	}
	
	public func timedOverlay<Item, Overlay: View>(item: Binding<Item?>, duration: TimeInterval, _ completion: (() -> ())? = nil, _ overlay: @escaping (Item) -> (Overlay)) -> some View {
		self.overlay(TimedOverlay(item: item, duration: duration, completion: completion, overlay: overlay))
	}
	
	@inlinable func eraseToAnyView() -> AnyView {
		AnyView(self)
	}
}

struct SuccessOverlay: View {
	var message: String
	
	var body: some View {
		VStack {
			Image(systemName: "checkmark.circle.fill")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 44)
				.foregroundColor(.toptalGreen)
			Text("\(message)").bold()
				.multilineTextAlignment(.center)
				.foregroundColor(.white)
		}
		.padding()
		.frame(maxWidth: 256)
		.background(Color.toptalDarkGrey.cornerRadius(8).opacity(0.8))
		.offset(y: -100)
	}
}

private struct TimedOverlay<Item, Overlay: View>: View {
	@Binding var item: Item?
	var duration: TimeInterval
	var completion: (() -> ())?
	var overlay: (Item) -> (Overlay)
	@State private var isFadingIn = false
	@State private var opacity: Double = 0
	
	public var body: some View {
		Group {
			if let item = item {
				overlay(item)
					.opacity(opacity)
			}
			else {
				EmptyView()
			}
		}
		.onReceive(item.publisher, perform: { _ in
			if item != nil, !isFadingIn {
				isFadingIn = true
				withAnimation { opacity = 1 }
				DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
					// after the duration, turn it off more quickly
					withAnimation(Animation.easeIn(duration: 0.2)) { opacity = 0 }
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
						// then clear the item
						item = nil
						isFadingIn = false
						
						completion?()
					}
				}
			}
			else if item == nil {
				// just in case
				opacity = 0
				isFadingIn = false
			}
		})
	}
}

struct ViewExtensions_Previews: PreviewProvider {
	static var previews: some View {
		Text("Hello, World!")
			.activityIndicator(true, message: "Loading...")
	}
}
