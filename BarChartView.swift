//
//  BarChartView.swift
//  Created by Michael Simms on 10/15/22.
//

//	MIT License
//
//  Copyright © 2023 Michael J Simms. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

import SwiftUI

struct Bar: Identifiable {
	let id: UUID = UUID()
	let value: Double
	let label: String
	let description: String
}

struct BarChartView: View {
	let bars: Array<Bar>
	let max: Double
	let color: Color
	let units: String
	let description: String
	@State private var showsAlert = false
	
	init(bars: [Bar], color: Color, units: String, description: String) {
		self.bars = bars
		self.max = bars.map { $0.value }.max() ?? 0
		self.color = color
		self.units = units
		self.description = description
	}
	
	var body: some View {
		GeometryReader { geometry in
			HStack(alignment: .bottom) {
				ForEach(self.bars) { bar in
					ZStack() {
						let height = CGFloat(bar.value) / CGFloat(self.max) * geometry.size.height
						Rectangle()
							.frame(height: height)
							.overlay(Rectangle().stroke(self.color).background(self.color))
							.accessibility(label: Text(bar.label + " " + self.units))
							.onTapGesture {
								self.showsAlert = true
							}
						Text(bar.label + " " + self.units)
							.font(.subheadline)
							.multilineTextAlignment(.center)
							.rotationEffect(Angle(degrees: -90))
							.frame(height: height)
					}
					.alert(isPresented: self.$showsAlert) { () -> Alert in
						Alert(title: Text("Description"), message: Text(self.description))}
				}
			}
		}
	}
}
