//
//  ChartDataSource.swift
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

public protocol DataSource {
  var chartSegments: [Segment] { get set }
  var maxValue: Double { get set }
}

extension DataSource {

  //MARK: - Item Helpers

  public func numberOfItems() -> Int {
    return chartSegments.count
  }

  public func item(index: Int) -> Segment? {
    guard index < chartSegments.count
          && index >= 0 else {
      return nil
    }
    return chartSegments[index]
  }

  public func indexOf(item: Segment) -> Int {
    guard let index = chartSegments.indexOf({ (itemToCheck: Segment) -> Bool in
      return itemToCheck == item
    }) else {
      return NSNotFound
    }
    return index
  }

  public func totalValue() -> Double {
    let value = chartSegments.reduce(0) { (sum, next) -> Double in
      return sum + next.value
    }
    return value
  }

  public func maxValue() -> Double {
    return max(totalValue(), maxValue)
  }

  public func isFullCircle() -> Bool {
    return maxValue <= totalValue()
  }

  //MARK: - Data Manipulation

  public mutating func remove(index: Int) -> Segment? {
    guard let _ = item(index) else {
      return nil
    }
    return chartSegments.removeAtIndex(index)
  }

  public mutating func insert(item: Segment, index: Int) {
    chartSegments.insert(item, atIndex: index)
  }

  public mutating func append(item: Segment) {
    chartSegments.append(item)
  }

  //MARK: - Public Angle Helpers
  
  public func endAngle() -> CGFloat {
    return endAngle(numberOfItems() - 1)
  }
  
  //MARK: - Angle Helpers

  func startAngle(index: Int) -> CGFloat {
    let rangeBounds = min(chartSegments.count, index)
    let slice = chartSegments[0..<rangeBounds]
    let angle = slice.enumerate().reduce(0) { (sum, next) -> CGFloat in
      return sum + arcAngle(next.0)
    }
    return angle
  }

  func endAngle(index: Int) -> CGFloat {
    return startAngle(index) + arcAngle(index)
  }

  func arcAngle(index: Int) -> CGFloat {
    guard let segment = item(index) where maxValue() > 0 else {
      return 0
    }
    let angle = segment.value / maxValue() * 2 * M_PI
    return CGFloat(angle)
  }
}
