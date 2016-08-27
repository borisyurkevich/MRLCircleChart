//
//  Segment.swift
//  MRLCircleChart
//
//  Created by Marek Lisik on 27/03/16.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

/**
 Defines values for a a single data point in the pie chart, a sorted
 collection of these is used by the chart's data source to calculate drawing
 angles as well as to provide value descriptions for it's accessory views.
 Note: this class and it's subclasses are `Comparable` by their's `value`
 property, and `Equatable` on both `value` and `description properties.
 */
public struct ChartSegment: Comparable {
  
  /**
   Value that the instance represents
   */
  public var value: Double
  
  /**
   String description to accompany the `ChartSegment's value
   */
  public var valueDescription: String
  
  /**
   Default initializer for `ChartSegment`, returns a fully configured
   instance.
   
   - parameter value:       UInt, value to represent
   - parameter description: String, description to accompany `ChartSegment's` value
   
   - returns: `ChartSegment` instance
   */
  public init(value: Double, description: String) {
    self.value = value
    self.valueDescription = description
  }
}

public func == (lhs: ChartSegment, rhs: ChartSegment) -> Bool {
  return lhs.value == rhs.value && lhs.valueDescription == rhs.valueDescription
}

public func < (lhs: ChartSegment, rhs: ChartSegment) -> Bool {
  return lhs.value < rhs.value
}

public func > (lhs: ChartSegment, rhs: ChartSegment) -> Bool {
  return lhs.value > rhs.value
}
