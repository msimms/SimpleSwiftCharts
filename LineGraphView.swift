//
//  LineGraphView.swift
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

struct Line: Shape {
	let points: Array<LinePoint>
	let origin: CGPoint
	let minX: Double
	let maxX: Double
	let minY: Double
	let maxY: Double
	let rangeX: Double
	let rangeY: Double
	
	init(points: Array<LinePoint>, origin: CGPoint) {
		self.points = points
		self.origin = origin
		self.minX = Double(self.points.map { $0.x }.min() ?? 0)
		self.maxX = Double(self.points.map { $0.x }.max() ?? 0)
		self.minY = self.points.map { $0.y }.min() ?? 0
		self.maxY = self.points.map { $0.y }.max() ?? 0
		self.rangeX = self.maxX - self.minX
		self.rangeY = self.maxY - self.minY
	}
	
	func path(in rect: CGRect) -> Path {
		let canvasSpreadX: Double = rect.width - rect.origin.x
		let canvasSpreadY: Double = rect.origin.y - rect.height
		var lastX = rect.origin.x
		var path = Path()
		
		path.move(to: origin)
		
		for point in self.points {
			let offsetX = Double(point.x) - self.minX
			let percentageX = offsetX / self.rangeX
			let canvasX = origin.x + (canvasSpreadX * percentageX)
			
			let offsetY = point.y - self.minY
			let percentageY = offsetY / self.rangeY
			let canvasY = origin.y + (canvasSpreadY * percentageY)
			
			path.addLine(to: CGPoint(x: canvasX, y: canvasY))
			lastX = canvasX
		}
		
		path.addLine(to: CGPoint(x: lastX, y: origin.y))
		path.closeSubpath()
		
		return path
	}
}

struct LinePoint: Identifiable {
	let id: UUID = UUID()
	let x: UInt64
	let y: Double
}

struct LinePopoverView: View {
	let xStr: String
	let yStr: String
	
	var body: some View {
		VStack {
			Text(xStr + ", " + yStr)
				.padding()
		}
		.padding()
	}
}

struct LineGraphView: View {
	@State var isPopover = false
	@State var hoverIndex: size_t = 0
	let points: Array<LinePoint>
	let color: Color
	let xFormatter: ((_ num: Double) -> String)?
	let yFormatter: ((_ num: Double) -> String)?
#if os(macOS)
#else
	@State private var orientation = UIDevice.current.orientation
#endif
	
	init(points: [(UInt64, Double)], color: Color, xFormatter: ((_ num: Double) -> String)?, yFormatter: ((_ num: Double) -> String)?) {
		self.points = points.map { LinePoint(x:$0, y:$1) }
		self.color = color
		self.xFormatter = xFormatter
		self.yFormatter = yFormatter
	}
	
	func textSize(_ text: String, maxWidth: CGFloat = .greatestFiniteMagnitude) -> CGSize {
		let boundingBox = NSString(string: text).boundingRect(
			with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
			options: [.usesLineFragmentOrigin, .usesFontLeading],
			context: nil
		)
		return CGSize(width: ceil(boundingBox.width), height: ceil(boundingBox.height))
	}
	
	func formatXAxisValue(num: Double) -> String {
		if self.xFormatter == nil {
			return String(num)
		}
		return self.xFormatter!(num)
	}
	
	func formatYAxisValue(num: Double) -> String {
		if self.yFormatter == nil {
			return String(num)
		}
		return self.yFormatter!(num)
	}
	
	var body: some View {
		GeometryReader { geometry in
			Group() {
#if os(macOS)
				let canvasMinX: Double = 45.0
				let canvasMinY: Double = 5.0
				let numXHashmarks: Int = 10
				let numYHashmarks: Int = 5
#else
				let canvasMinX: Double = self.orientation.isLandscape ? 45.0 : 15.0
				let canvasMinY: Double = self.orientation.isLandscape ? 5.0 : 15.0
				let numXHashmarks: Int = self.orientation.isLandscape ? 10 : 5
				let numYHashmarks: Int = self.orientation.isLandscape ? 5 : 10
#endif
				let hashMarkLength: Double = 15.0
				let axisWidth: Double = 4.0
				let canvasMaxX: Double = geometry.size.width
				let canvasMaxY: Double = geometry.size.height - canvasMinY
				let origin: CGPoint = CGPoint(x: canvasMinX, y: canvasMaxY + axisWidth / 2)
				let xAxisTop: CGPoint = CGPoint(x: canvasMaxX, y: origin.y)
				let yAxisTop: CGPoint = CGPoint(x: origin.x, y: canvasMinY - axisWidth)
				var tempAxisXOffset: Double = canvasMaxX
				var tempAxisYOffset: Double = canvasMaxY
				let xAxisHashMarkSpacing = (canvasMaxX / Double(numXHashmarks))
				let yAxisHashMarkSpacing = (canvasMaxY - canvasMinY) / Double(numYHashmarks)
#if os(macOS)
				let components = Color(self.color).cgColor?.components! ?? [0.5, 0.5, 0.5, 1.0]
				let fadedColor = Color(red: components[0] * 0.5, green: components[1] * 0.5, blue: components[2] * 0.5)
#else
				let components = UIColor(self.color).cgColor.components!
				let fadedColor = Color(red: components[0] * 0.5, green: components[1] * 0.5, blue: components[2] * 0.5)
#endif
				let gradient = LinearGradient(
					gradient: .init(colors: [self.color, fadedColor]),
					startPoint: .top,
					endPoint: .bottom
				)
				
				Group() {
					
					// Draw the axis lines.
					Path { path in
						
						// X axis
						path.move(to: origin)
						path.addLine(to: xAxisTop)
						
						// Y axis
						path.move(to: origin)
						path.addLine(to: yAxisTop)
					}
					.stroke(.gray, lineWidth: axisWidth)
					
					// Draw the X axis hash marks.
					Path { path in
						for _ in 1...numXHashmarks {
							let canvasX: Double = canvasMinX + (canvasMaxX - tempAxisXOffset)
							tempAxisXOffset -= xAxisHashMarkSpacing
							
							path.move(to: CGPoint(x: canvasX, y: canvasMaxY))
							path.addLine(to: CGPoint(x: canvasX, y: canvasMaxY + hashMarkLength))
						}
					}
					.stroke(.gray, lineWidth: axisWidth / 2)
					
					// Draw the Y axis hash marks.
					Path { path in
						for _ in 1...numYHashmarks {
							let canvasY: Double = canvasMinY + (canvasMaxY - tempAxisYOffset)
							tempAxisYOffset -= yAxisHashMarkSpacing
							
							// Don't draw past the axis line.
							if tempAxisYOffset <= yAxisTop.y {
								break
							}
							
							path.move(to: CGPoint(x: canvasMinX, y: canvasY))
							path.addLine(to: CGPoint(x: canvasMinX - hashMarkLength, y: canvasY))
						}
					}
					.stroke(.gray, lineWidth: axisWidth / 2)
					
					// Draw the data line.
					let lineWidth: Double = xAxisTop.x - origin.x
					let lineHeight: Double = origin.y - yAxisTop.y
					if lineWidth > 0 && lineHeight > 0 {
						Line(points: self.points, origin: origin)
							.fill(gradient)
							.frame(width: lineWidth, height: lineHeight)
							.onContinuousHover { phase in
								switch phase {
								case .active(let location):
									self.hoverIndex = size_t(CGFloat(location.x / canvasMaxX) * CGFloat(self.points.count))
									self.isPopover = !self.isPopover
								case .ended:
									self.isPopover = false
								}
							}
							.onTapGesture(count: 1) { location in
								self.hoverIndex = size_t(CGFloat(location.x / canvasMaxX) * CGFloat(self.points.count))
								self.isPopover.toggle()
							}
#if os(macOS)
							.popover(isPresented: self.$isPopover) {
								let pt: LinePoint = self.points[self.hoverIndex]
								LinePopoverView(xStr: self.formatXAxisValue(num: Double(pt.x)), yStr: self.formatYAxisValue(num: pt.y))
							}
#else
							.sheet(isPresented: self.$isPopover) {
								let pt: LinePoint = self.points[self.hoverIndex]
								LinePopoverView(xStr: self.formatXAxisValue(num: Double(pt.x)), yStr: self.formatYAxisValue(num: pt.y))
							}
#endif
					}
				}
				
				Group() {
					
					// Add the Y axis labels.
					let minY = self.points.map { $0.y }.min() ?? 0.0
					let maxY = self.points.map { $0.y }.max() ?? 0.0
					let rangeY = maxY - minY
					ForEach(0..<numYHashmarks, id: \.self) { i in
						let canvasYOffset: Double = Double(i) * yAxisHashMarkSpacing
						let canvasY: Double = canvasMinY + (canvasMaxY - canvasYOffset)
						let axisStep: Double = Double(i) * (rangeY / Double(numYHashmarks))
						let axisValue: Double = minY + axisStep
						let formattedValue: String = self.formatYAxisValue(num: axisValue)
						let textSize = self.textSize(formattedValue)
						
						// Don't draw past the axis line.
						if canvasY > yAxisTop.y {
							Text(formattedValue)
								.frame(maxWidth: .infinity, alignment: .center)
								.position(x: origin.x - textSize.width - 2, y: canvasY - canvasMinX - 10.0)
						}
					}
				}
				
				Group() {
					
					// Add the X axis labels.
					let minX = self.points.map { Double($0.x) }.min() ?? 0.0
					let maxX = self.points.map { Double($0.x) }.max() ?? 0.0
					let rangeX = maxX - minX
					ForEach(0..<numXHashmarks, id: \.self) { i in
						let canvasXOffset: Double = Double(i) * xAxisHashMarkSpacing
						let canvasX: Double = canvasMinX + canvasXOffset
						let axisStep: Double = Double(i) * (rangeX / Double(numXHashmarks))
						let axisValue: Double = minX + axisStep
						let formattedValue: String = self.formatXAxisValue(num: axisValue)
						let textSize = self.textSize(formattedValue)
						
						Text(formattedValue)
							.rotationEffect(Angle(degrees: 270))
							.frame(maxWidth: .infinity, alignment: .center)
							.position(x: canvasX, y: origin.y + textSize.width + 2)
					}
				}
			}
		}
	}
}
