//
//  ChartViewSnapshotTestCase.swift
//  MRLCircleChart
//
//  Created by Marek Lisik on 27/08/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import Nimble_Snapshots
import UIKit

@testable import MRLCircleChart

struct Configuration {
  static let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 128, height: 128))
  static let lineWidth: CGFloat = 20
  static let emptyDataSource: MRLCircleChart.ChartDataSource = MRLCircleChart.NumberChartDataSource(items: [], maxValue: 100)
  static let dataSource: MRLCircleChart.ChartDataSource = MRLCircleChart.NumberChartDataSource(items: [10,20,30], maxValue: 100)
}

protocol SnapshotSpec {
  var recordMode: Bool { get set }
  func testSnapshot() -> MatcherFunc<Snapshotable>
}

extension SnapshotSpec {
  func testSnapshot() -> MatcherFunc<Snapshotable> {
    switch recordMode {
    case false: return haveValidSnapshot(named: nil, usesDrawRect: false, tolerance: 1)
    case true: return recordSnapshot()
    }
  }
  
}

class ChartViewSnapshotTestCase: QuickSpec, SnapshotSpec {
  
  var recordMode: Bool = false
  
  override func spec() {
    describe("Chart") {
      
      var chart: MRLCircleChart.Chart!
      
      beforeEach() {
        chart = MRLCircleChart.Chart(
          frame: Configuration.frame ,
          lineWidth: Configuration.lineWidth,
          dataSource: Configuration.emptyDataSource
        )
      }
      
      context("when it has an empty data source") {
        
        beforeEach() {
          chart.dataSource = Configuration.emptyDataSource
        }
        
        it("should have the correct state") {
          chart.reloadData(animated: false)
          expect(chart).toEventually(self.testSnapshot())
        }
        
        context("when it has background colour defined") {
          beforeEach() {
            chart.chartBackgroundColor = UIColor.red
          }
          
          it("should have the correct background color") {
            chart.reloadData(animated: false)
            expect(chart).toEventually(self.testSnapshot())
          }
        }
      }
      
      context("when it has dataSource filled in") {
        
        beforeEach() {
          chart.dataSource = Configuration.dataSource
          chart.reloadData(animated: false)
        }
        
        it("should have the correct state") {
          expect(chart).toEventually(self.testSnapshot())
        }
        
        context("and begin-end colors defined") {
          beforeEach() {
            chart.beginColor = UIColor.yellow
            chart.endColor = UIColor.green
            chart.reloadData(animated: false)
          }
          
          it("should have the correct pallette") {
            expect(chart).toEventually(self.testSnapshot())
          }
        }
        
        context("with default .Grow selection type") {
          beforeEach() {
            chart.padding = 20
            chart.reloadData(animated: false)
          }
          
          it("should animate out on selection") {
            chart.select(index: 0)
            expect(chart).toEventually(self.testSnapshot(), timeout: 1.5, pollInterval: 0.1, description: nil)
          }
          
          it("should animate back in on deselection") {
          
            chart.deselect(index: 0)
            
            expect(chart).toEventually(self.testSnapshot(), timeout: 3, pollInterval: 0.5, description: nil)
          }
        }
        
        context("when an item is removed") {
          beforeEach() {
            _ = chart.dataSource?.remove(at: 0)
          }
          
          it("should reflect the state of the data source") {
            chart.reloadData(animated: false)
            expect(chart).toEventually(self.testSnapshot())
          }
        }
        
        context("when an item is added") {
          beforeEach() {
            chart.dataSource?.append(ChartSegment(value: 15, description: ""))
          }
          
          it("should reflect the state of the data source") {
            chart.reloadData(animated: false)
            expect(chart).toEventually(self.testSnapshot())
          }
        }
      }
    }
  }
}
