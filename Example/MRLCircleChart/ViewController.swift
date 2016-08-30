//
//  ViewController.swift
//  MRLCircleChart
//
//  Created by mlisik on 27/03/2016.
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

import UIKit
import MRLCircleChart

struct Data {
  static let maxValue: Double = 1000
  static let values: [Double] = [10, 20, 40, 30, 10, 80, 90, 100, 200, 250, 80, 90]
}

class ViewController: UIViewController {
  
  //MARK: - IBOutlets
  
  @IBOutlet var chart: MRLCircleChart.Chart!
  
  //MARK: - Instance Variables
  
  var dataSource = MRLCircleChart.NumberChartDataSource(items: Data.values, maxValue: Data.maxValue)
  
  //MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupChart()
    runDemo()
  }
  
  //MARK: - Setup
  
  private func setupChart() {
    chart.dataSource = dataSource
    chart.selectHandler = { index in print("selected \(index)") }
    chart.deselectHandler = { index in print("deselected \(index)") }
  }
  
  //MARK: - DemoActions
  
  private func runDemo() {
    func runAfter(time: Double, block: () -> ()) {
      let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC)))
      dispatch_after(delay, dispatch_get_main_queue(), {
        block()
      })
    }
    
    runAfter(1) {
      self.chart.reloadData()
    }
    
    runAfter(2) {
      self.chart.select(index: 1)
    }
  }
  
  //MARK: - Actions
  
  @IBAction func reverseButtonTapped(sender: UIButton) {
    dataSource.segments = dataSource.segments.reverse()
    chart.reloadData()
  }
  
  @IBAction func addButtonTapped(sender: UIButton) {
    
    sender.enabled = false
    
    let value: Double = Double(random() % 75  + 25)
    dataSource.append(ChartSegment(value: value, description: "value: \(value)"))
    
    chart.reloadData() {
      sender.enabled = true
    }
  }
  
  @IBAction func removeButtonTapped(sender: UIButton) {
    
    guard dataSource.numberOfItems() > 0 else {
      return
    }
    
    sender.enabled = false
    
    dataSource.remove(dataSource.numberOfItems() - 1)
    chart.reloadData() {
      sender.enabled = true
    }
  
  }
}