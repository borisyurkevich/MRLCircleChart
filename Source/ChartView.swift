//
//  Chart.swift
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

import UIKit

/**
 Chart is a `UIView` subclass that provides a graphical representation
 of it's data source in the form of a pie chart. It manages an array of
 SegmentLayers that draw each segment of the chart individually, and relies
 on it's data source for relaying values (also angle values) for each layer.
 */
@objc
open class Chart: UIView {
  
  //MARK: - Public Handlers
  
  public typealias SelectionHandler = (Int) -> ()
  
  /**
   Ran when user selects a layer via touch interaction.
   */
  open var selectHandler: SelectionHandler = {index in }
  
  /**
   Ran when a segment is deselected as a result of direct touch interaction
   */
  open var deselectHandler: SelectionHandler = {index in }
  
  //MARK: - Public variables
  
  /**
   `ChartDataSource` providing reference items and angle calulations for `Chart`'s segments
   */
  open var dataSource: ChartDataSource?
  
  //MARK: - Public Inspectables
  
  // Width of the `Chart`'s segments
  @IBInspectable open var lineWidth: CGFloat = 25
  // `Chart`'s inner padding if you need to make it smaller than it's bounds
  @IBInspectable open var padding: CGFloat = 0
  // Colour of `Chart`'s background segment
  @IBInspectable open var chartBackgroundColor: UIColor = UIColor(white: 0.7, alpha: 0.66)
  // Color for `Chart`'s first segment
  @IBInspectable open var beginColor: UIColor?
  // Color for `Chart`'s last segment
  @IBInspectable open var endColor: UIColor?
  
  //MARK: - Private variables
  
  fileprivate var chartBackgroundSegment: ChartSegmentLayer?
  fileprivate var chartSegmentLayers: [ChartSegmentLayer] = []
  fileprivate var colorPalette: [UIColor] = []
  fileprivate var selectionStyle: SegmentSelectionStyle = .grow
  
  //MARK: - Initializers
  
  /**
   Default initializer for ChartView, provides most of the customization points
   
   Note: `innerRadius` and `outerRadius` are initially used to calculate a ratio
   of these values to overal chart frame, so that the chart is sized correclty
   when changes to the frame are made
   
   Note: `beginColor` and `endColor` are used to derive a range, or gradient of
   colors, that provide a smooth transition between each segment
   
   - parameter frame:       frame used to display the chart view; since chart
   itself requires square bounds, the greates square frame that fits in the
   frame is derived and centered in chart frame
   - parameter lineWidth:   the width of chart's line
   - parameter dataSource:  `DataSource` complying object that provides all
   data details for the chart view
   - parameter beginColor:  color of the first chart segment layer
   - parameter endColor:    color of the last chart segment layer
   
   - returns: fully configured chart view
   */
  public required init(frame: CGRect, lineWidth: CGFloat, dataSource: ChartDataSource, beginColor: UIColor = UIColor.green, endColor: UIColor = UIColor.yellow) {
    self.lineWidth = lineWidth
    self.dataSource = dataSource
    self.beginColor = beginColor
    self.endColor = endColor
    
    super.init(frame: frame)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  //MARK: - Public Overrides
  
  override open func layoutSubviews() {
    super.layoutSubviews()
    updateSegmentsBounds()
    setupBackgroundSegmentIfNeeded()
  }
  
  //MARK: - Setup
  
  /**
   Updates individual layer positoins according to bounds changes
   */
  fileprivate func updateSegmentsBounds() {
    for layer in chartSegmentLayers {
      layer.frame = bounds.largestSquareThatFits()
    }
  }
  
  /**
   Sets up background segment if needed
   */
  fileprivate func setupBackgroundSegmentIfNeeded() {
    if let backgroundSegment = chartBackgroundSegment {
      backgroundSegment.frame = bounds.largestSquareThatFits()
    } else {
      let backgroundSegment = ChartSegmentLayer(frame: bounds.largestSquareThatFits(), start: 0, end: CGFloat(M_PI * 2), lineWidth: lineWidth, padding: padding, color: chartBackgroundColor.cgColor)
      layer.insertSublayer(backgroundSegment, at: 0)
      chartBackgroundSegment = backgroundSegment
    }
  }
  
  /**
   Setups `colorPalette` based on `beginColor` and `endColor`.
   */
  fileprivate func setupColorPalettes() {
    
    guard let source = dataSource else {
      return
    }
    
    colorPalette = UIColor.colorRange(
      beginColor: beginColor!,
      endColor: endColor!,
      count: source.numberOfItems()
    )
  }
  
  /**
   Querries the `dataSource` for data and inserts, removes, or updates all relevant segments.
   
   - parameter animated: specifies whether the operation will be animated, defaults to `true`
   - parameter completion: optional completion block, defaults to `{}`
   */
  final public func reloadData(animated: Bool = true, completion: @escaping () -> () = {}) {
    guard let source = dataSource else {
      return
    }
    
    setupColorPalettes()
    
    let refNumber = max(source.numberOfItems(), chartSegmentLayers.count)
    
    var indexesToRemove: [Int] = []
    
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    CATransaction.setDisableActions(!animated)
    
    for index in 0..<refNumber {
      
      guard let _ = source.item(at: index) else {
        indexesToRemove.append(index)
        continue
      }
      
      guard let layer = layer(at: index) else {
        let layer = ChartSegmentLayer(
          frame: self.bounds.largestSquareThatFits(),
          start: source.startAngle(for: index),
          end: source.endAngle(for: index),
          lineWidth: lineWidth,
          padding: padding,
          color: colorPalette[index].cgColor
        )
        self.layer.insertSublayer(layer, at: 1)
        chartSegmentLayers.append(layer)
        
        if animated {
          layer.animateInsertion(
            source.isFullCircle() ? 0 : source.startAngle(for: index),
            endAngle: source.isFullCircle() ? 0 : CGFloat(M_PI * 2)
          )
        }
        
        continue
      }
      
      layer.startAngle = source.startAngle(for: index)
      layer.endAngle = source.endAngle(for: index)
      layer.color = colorPalette[index].cgColor
      layer.lineWidth = lineWidth
      layer.padding = padding
    }
    
    for index in indexesToRemove.reversed() {
      guard let layer = layer(at: index) else {
        continue
      }
      
      CATransaction.begin()
      CATransaction.setCompletionBlock({
        layer.removeFromSuperlayer()
      })
      
      layer.startAngle = 0
      layer.endAngle = 0
      
      chartSegmentLayers.remove(at: index)
      CATransaction.commit()
    }
    
    reassignSegmentLayerscapTypes()
    CATransaction.commit()
  }
  
  /**
   Empties the `dataSource` and reloadsData() to clear all segments. Animates changes by default.
   */
  open func empty(animated: Bool = true, color: UIColor? = nil) {
    guard var source = dataSource else {
      return
    }
    
    if let layerColor = color {
      for layer in chartSegmentLayers {
        layer.color = layerColor.cgColor
      }
    }
    
    source.empty()
    reloadData(animated: animated)
  }
  
  //MARK: - Layer manipulation
  
  /**
   Loops through the available layers and assigns them appropriate end cap type
   */
  fileprivate func reassignSegmentLayerscapTypes() {
    
    guard let source = dataSource else {
      return
    }
    
    for (index, segment) in chartSegmentLayers.enumerated() {
      if source.isFullCircle() {
        segment.capType = .none
      } else {
        switch index {
        case 0 where chartSegmentLayers.count > 1:
          segment.capType = .begin
        case 0 where chartSegmentLayers.count == 1:
          segment.capType = .bothEnds
        case chartSegmentLayers.count - 1 where chartSegmentLayers.count > 1:
          segment.capType = .end
        default:
          segment.capType = .none
        }
      }
    }
  }
  
  /**
   Returns a `ChartSegmentLayer?` for a given index
   
   - parameter index: Int, index to look at
   - returns: an optional value that's `nil` when index is out of bounds, and
   ChartSegmentLayer when a value is found
   */
  fileprivate func layer(at index: Int) -> ChartSegmentLayer? {
    if index >= chartSegmentLayers.count || index < 0 {
      return nil
    } else {
      return chartSegmentLayers[index]
    }
  }
  
  /**
   Removes the layer at a given index
   
   - parameter index:    index to remove
   - parameter animated: defaults to `true`, specifies whether the removal
   should be animated
   */
  fileprivate func remove(_ index: Int, startAngle: CGFloat = CGFloat(M_PI * 2), endAngle: CGFloat = CGFloat(M_PI * 2), animated: Bool = true) {
    
    guard let layer = layer(at: index) else {
      return
    }
    
    if animated {
      layer.animateRemoval(startAngle: startAngle, endAngle: endAngle, completion: {
        self.reassignSegmentLayerscapTypes()
      })
    } else {
      layer.removeFromSuperlayer()
      reassignSegmentLayerscapTypes()
    }
  }
  
  //MARK: - Touches
  
  /**
   Utility function enabling manual segment selection from your code.
   
   *Note:* this will not run any of the selection handlers
   
   - parameter selectIndex: index to select
   */
  open func select(index selectIndex: Int) {
    
    if chartSegmentLayers.count == 0 {
      return
    }
    
    if let _ = layer(at: selectIndex) {
      switch selectionStyle {
      case .none:
        break
      case .grow:
        for (index, layer) in chartSegmentLayers.enumerated() {
          layer.selected = index == selectIndex ? !layer.selected : false
          layer.lineWidth = layer.selected ? lineWidth + 10 : lineWidth
          layer.padding = layer.selected ? padding - 10 : padding
        }
      }
    }
  }
  
  
  /**
   Utility function enabling segment deselection from your code.
   
   *Note:* this will not run any of the selection handlers
   
   - parameter se
   */
  open func deselect(index: Int) {
    if chartSegmentLayers.count == 0 {
      return
    }
    
    if let layer = layer(at: index) {
      switch selectionStyle {
      case .none:
        break
      case .grow:
        layer.selected = false
        layer.lineWidth = lineWidth
        layer.padding = padding
      }
    }
  }
  
  fileprivate func selected() -> Int? {
    for (index, layer) in chartSegmentLayers.enumerated() {
      if layer.selected {
        return index
      }
    }
    return nil
  }
  
  open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first,
      let firstLayer = chartSegmentLayers.first else {
        return
    }
    
    let point = firstLayer.convert(touch.location(in: self), from: self.layer)
    
    for (index, layer) in chartSegmentLayers.enumerated() {
      if layer.contains(point) {
        if layer.selected {
          deselectHandler(index)
          deselect(index: index)
        } else {
          selectHandler(index)
          select(index: index)
        }
        return
      } else {
        if layer.selected {
          deselectHandler(index)
          deselect(index: index)
        }
      }
    }
  }
}
