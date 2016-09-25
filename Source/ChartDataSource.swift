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

/**
 Protocol defining setup requirements for a `Chart`'s `dataSource`
 */
public protocol ChartDataSource {
  var segments: [ChartSegment] { get set }
  var maxValue: Double { get set }
}

extension ChartDataSource {
  
  //MARK: - Item Helpers
  
  /**
   Utility function that returns count of items
   */
  public func numberOfItems() -> Int {
    return segments.count
  }
  
  /**
   Utitlity function that return sthe item at a given index
   
   - parameter index: index to check
   
   - returns: nil if no item found at index, or a `ChartSegment` if found
   */
  public func item(at index: Int) -> ChartSegment? {
    guard index < segments.count
      && index >= 0 else {
        return nil
    }
    return segments[index]
  }
  
  /**
   Utility function that returns the index of a given item
   
   - parameter item: ChartSegment to be checked
   
   - returns: `nil` if `item` is not found, otherwise the index
   */
  public func index(of item: ChartSegment) -> Int? {
    guard let index = segments.index(where: { (itemToCheck: ChartSegment) -> Bool in
      return itemToCheck == item
    }) else {
      return nil
    }
    return index
  }
  
  /**
   Utility function that returns the total value of all segments added up
   */
  public func totalValue() -> Double {
    let value = segments.reduce(0) { (sum, next) -> Double in
      return sum + next.value
    }
    return value
  }
  
  /**
   Utility function that returns the value represented by a full circle
   */
  public func maxValue() -> Double {
    return max(totalValue(), maxValue)
  }
  
  /**
   Utility function that checks whether segments fill the whole chart
   */
  public func isFullCircle() -> Bool {
    return maxValue <= totalValue()
  }
  
  //MARK: - Data Manipulation
  
  /**
   Removes item at a given index and returns it
   
   - paramameter index: index for the item to remove, should be `index < segments.count`
   
   - returns: ChartSegment? nil or ChartSegment at the given index
   */
  public mutating func remove(at index: Int) -> ChartSegment? {
    guard let _ = item(at: index) else {
      return nil
    }
    return segments.remove(at: index)
  }
  
  /**
   Inserts an item at a given index
   
   - parameter item `ChartSegment` to insert
   - parameter index index to insert it at, requires `index <= segments.count`
   */
  public mutating func insert(_ item: ChartSegment, index: Int) {
    guard index <= segments.count else {
      return
    }
    
    segments.insert(item, at: index)
  }
  
  /**
   Appends an item at the end of `segments`
   
   - parameter item ChartSegment to append
  */
  public mutating func append(_ item: ChartSegment) {
    segments.append(item)
  }
  
  /**
   Empties `segments` by removing all items.
   */
  public mutating func empty() {
    while segments.count > 0 {
      remove(at: 0)
    }
  }
  
  //MARK: - Public Angle Helpers
  
  /**
   Utility function for retrieving the end angle of the last segment
   
   - returns: end angle for the last segment or 0 if no segments are found
   */
  public func endAngle() -> CGFloat {
    return endAngle(for: numberOfItems() - 1)
  }
  
  //MARK: - Angle Helpers
  
  /**
   Checks start angle of a segment at a given index by adding up end angle values of all previous segments
   
   - parameter index: index of segment to check
   
   - returns: CGFloat start angle of the segment or 0 if no segment found
   */
  func startAngle(for index: Int) -> CGFloat {
    guard let _ = item(at: index), maxValue() > 0 else {
      return 0
    }
    
    let slice = segments[0..<min(segments.count, index)]
    let angle = slice.enumerated().reduce(0) { (sum, next) -> CGFloat in
      return sum + arcAngle(for: next.0)
    }
    
    return angle
  }
  
  /**
   Checks the end angle of a segment at a given `index` in `segments`
   
   - parameter index: index of segment to check
   
   - returns: CGFloat end angle of the segment or 0 if no segment found
   */
  func endAngle(for index: Int) -> CGFloat {
    return startAngle(for: index) + arcAngle(for: index)
  }
  
  /**
   Checks for the arc angle of a segment at a given `index` in `segments`
   
   - parameter index: index of segment to check
   
   - returns: CGFloat length of the arc or 0 if no segment found
   */
  func arcAngle(for index: Int) -> CGFloat {
    guard let segment = item(at: index), maxValue() > 0 else {
      return 0
    }
    let angle = segment.value / maxValue() * 2 * M_PI
    return CGFloat(angle)
  }
}
