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
  
  fileprivate func setupChart() {
    chart.dataSource = dataSource
    chart.selectHandler = { index in print("selected \(index)") }
    chart.deselectHandler = { index in print("deselected \(index)") }
  }
  
  //MARK: - DemoActions
  
  fileprivate func runDemo() {
    func runAfter(_ time: Double, block: @escaping () -> ()) {
      let delay = DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
      DispatchQueue.main.asyncAfter(deadline: delay, execute: {
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
  
  @IBAction func reverseButtonTapped(_ sender: UIButton) {
    dataSource.segments = dataSource.segments.reversed()
    chart.reloadData()
  }
  
  @IBAction func addButtonTapped(_ sender: UIButton) {
    
    sender.isEnabled = false
    
    let value: Double = Double(arc4random() % 75  + 25)
    dataSource.append(ChartSegment(value: value, description: "value: \(value)"))
    
    chart.reloadData() {
      sender.isEnabled = true
    }
  }
  
  @IBAction func removeButtonTapped(_ sender: UIButton) {
    
    guard dataSource.numberOfItems() > 0 else {
      return
    }
    
    sender.isEnabled = false
    
    _ = dataSource.remove(at: dataSource.numberOfItems() - 1)
    chart.reloadData() {
      sender.isEnabled = true
    }
  
  }
}
