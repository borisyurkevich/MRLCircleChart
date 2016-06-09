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

class DataSource: MRLCircleChart.DataSource {
  var chartSegments: [MRLCircleChart.Segment]
  var maxValue: Double
  
  init(items: [MRLCircleChart.Segment], maxValue: Double) {
    self.chartSegments = items
    self.maxValue = maxValue
  }
}

class ViewController: UIViewController {
  
  @IBOutlet var chart: MRLCircleChart.Chart?
  
  var dataSource = DataSource(items: [], maxValue: Data.maxValue)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupData()
    
    if let tempChart = chart {
      tempChart.dataSource = dataSource
      tempChart.selectionStyle = .DesaturateNonSelected
      tempChart.delegate = self
      
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
        // let's pretend our async API call has finished
        tempChart.reloadData()
      }

      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
        tempChart.animateDepletion(UIColor.redColor(), fromAngle: self.dataSource.endAngle())
      }
    }
  }
  
  private func setupData() {
    dataSource.chartSegments = Data.values.map { (value: Double) -> MRLCircleChart.Segment in
      return MRLCircleChart.Segment(value: value, description: "value: \(value)")
    }.sort { $0 < $1 }
  }
  
  //MARK: - Actions
  
  @IBAction func beginColorChanged(sender: UIButton) {
    sender.selected = !sender.selected
    
    chart!.beginColor! = sender.selected ? UIColor.greenColor() : UIColor.yellowColor()
  }
  
  @IBAction func endColorChanged(sender: UIButton) {
    sender.selected = !sender.selected
    chart!.endColor! = sender.selected ? UIColor.redColor() : UIColor.blueColor()
  }
  
  @IBAction func reverseValues(sender: UIButton) {
    dataSource.chartSegments = dataSource.chartSegments.reverse()
    chart!.reloadData()
  }
  
  @IBAction func addItem(sender: UIButton) {
    let value: Double = Double(random() % 75  + 25)
    dataSource.append(Segment(value: value, description: "value: \(value)"))
    dataSource.chartSegments.sortInPlace { $0 < $1 }
    chart!.reloadData()
  }
  
  @IBAction func removeItem(sender: UIButton) {
    if dataSource.numberOfItems() > 0 {
      dataSource.remove(dataSource.numberOfItems() - 1)
      chart!.reloadData()
    }
  }
}

extension ViewController: MRLCircleChart.Delegate {
  func chartDidSelectItem(index: Int) {
    print("selected item with index: \(index)")
  }
}