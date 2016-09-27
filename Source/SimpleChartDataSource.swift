//
//  SimpleChartDataSource.swift
//  Pods
//
//  Created by Marek Lisik on 27/08/16.
//
//

import Foundation


/**
 Convenience implementation of `ChartDataSource` that can be initialized with a `[Number]` and will create segments
 */
open class NumberChartDataSource: ChartDataSource {
  open var segments: [ChartSegment]
  open var maxValue: Double
  
  /**
   Designated initializer for `NumberChartDataSource`
   
   - parameter items: an array of `Number`-conforming numeric types
   - parameter maxValue: the initial maximum reference value for the chart segments angle calculations
   */
  public init(items: [Double], maxValue: Double) {
    self.segments = items.map {
      return ChartSegment(value: $0, description: "$0")
    }
    self.maxValue = maxValue
  }
}
