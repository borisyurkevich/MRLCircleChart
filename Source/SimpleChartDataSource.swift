//
//  SimpleChartDataSource.swift
//  Pods
//
//  Created by Marek Lisik on 27/08/16.
//
//

import Foundation

/**
 Dummy protocol that groups common numeric types
 */
public protocol Number {}

extension Float: Number {}
extension Double: Number {}
extension Int: Number {}
extension UInt: Number {}
extension CGFloat: Number {}

/**
 Convenience implementation of `ChartDataSource` that can be initialized with a `[Number]` and will create segments
 */
public class NumberChartDataSource<T where T: Number>: ChartDataSource {
  public var segments: [ChartSegment]
  public var maxValue: Double
  
  /**
   Designated initializer for `NumberChartDataSource`
   
   - parameter items: an array of `Number`-conforming numeric types
   - parameter maxValue: the initial maximum reference value for the chart segments angle calculations
   */
  public init(items: [T], maxValue: Double) {
    self.segments = items.flatMap {
      guard let number = $0 as? Double else {
        return nil
      }
      return ChartSegment(value: number, description: "value: \(number)")
    }
    self.maxValue = maxValue
  }
}
