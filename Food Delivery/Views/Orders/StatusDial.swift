//
//  StatusDial.swift
//  Food Delivery
//
//  Created by Steven Brooks on 11/6/20.
//

import SwiftUI

struct StatusDial: View {
	var status: Order.Status
	
	var body: some View {
		Meter(angle: needleAngle)
			// chop off the bottom where the circle isn't completed
			.offset(y: 30)
			.frame(width: 280, height: 220)
	}
	
	var needleAngle: Angle {
		// between -120 and 120
		let index = Order.Status.allCases.firstIndex(of: status) ?? 0
		
		let ratio = 240.0 / (Double(Order.Status.allCases.count) - 1)
		return Angle(degrees: (ratio * Double(index)) - 120)
	}
}

struct Meter: View {
	var angle = Angle(degrees: -120)
	var colors = [Color.appRed, Color.appGreen]
	
	var body: some View {
		ZStack {
			// gauge
			Circle()
				.inset(by: 21)
				.trim(from: 0.15, to: 0.85)
				.stroke(AngularGradient(gradient: Gradient(colors: colors), center: .center), lineWidth: 42)
				.rotationEffect(.init(degrees: 90))
				.frame(width: 280, height: 280)

			// needle
			Circle()
				.frame(width: 24, height: 24)
				.foregroundColor(.appDarkGray)
			
			Triangle()
				.frame(width: 12, height: 120)
				.offset(y: -60)
				.foregroundColor(.appDarkGray)
				.rotationEffect(angle)
				.animation(Animation.spring(response: 0.4, dampingFraction: 0.4, blendDuration: 0.3))
		}
	}
	
	private struct Triangle: Shape {
		func path(in rect: CGRect) -> Path {
			var path = Path()

			path.move(to: CGPoint(x: rect.midX, y: rect.minY))
			path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
			path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
			path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

			return path
		}
	}
}

struct StatusDial_Previews: PreviewProvider {
	static var previews: some View {
		
		ForEach(Order.Status.allCases, id: \.self) { status in
			StatusDial(status: status)
				.previewLayout(.sizeThatFits).padding()
		}
	}
}
