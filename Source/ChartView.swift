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
public class Chart: UIView {
  
  //MARK: - Public Handlers
  
  /**
   Ran when user selects a layer via touch interaction.
   */
  public var selectHandler: (Int) -> () = {index in }
  
  /**
   Ran when a segment is deselected as a result of direct touch interaction
   */
  public var deselectHandler: (Int) -> () = {index in }
  
  //MARK: - Public variables
  
  public var dataSource: DataSource?
  public var selectionStyle: SegmentSelectionStyle = .Grow
  
  //MARK: - Public Inspectables
  
  @IBInspectable public var lineWidth: CGFloat = 25
  @IBInspectable public var padding: CGFloat = 0
  @IBInspectable public var chartBackgroundColor: UIColor = UIColor(white: 0.7, alpha: 0.66)
  @IBInspectable public var beginColor: UIColor?
  @IBInspectable public var endColor: UIColor?
  @IBInspectable public var inactiveBeginColor = UIColor.inactiveBeginColor()
  @IBInspectable public var inactiveEndColor = UIColor.inactiveEndColor()
  
  //MARK: - Private variables
  
  private var chartBackgroundSegment: SegmentLayer?
  private var chartSegmentLayers: [SegmentLayer] = []
  private var colorPalette: [UIColor] = []
  private var grayscalePalette: [UIColor] = []
  
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
  public required init(frame: CGRect, lineWidth: CGFloat, dataSource: DataSource, beginColor: UIColor = UIColor.greenColor(), endColor: UIColor = UIColor.yellowColor()) {
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
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    updateSegmentsBounds()
    setupBackgroundSegmentIfNeeded()
  }
  
  //MARK: - Setup
  
  /**
   Updates individual layer positoins according to bounds changes
   */
  private func updateSegmentsBounds() {
    for layer in chartSegmentLayers {
      layer.frame = bounds.largestSquareThatFits()
      layer.transform = CATransform3DMakeRotation(CGFloat(-M_PI / 2), 0, 0, 1)
    }
  }
  
  /**
   Sets up background segment if needed
   */
  private func setupBackgroundSegmentIfNeeded() {
    if let backgroundSegment = chartBackgroundSegment {
      backgroundSegment.frame = bounds.largestSquareThatFits()
    } else {
      let backgroundSegment = SegmentLayer(frame: bounds.largestSquareThatFits(), start: 0, end: CGFloat(M_PI * 2), lineWidth: lineWidth, padding: padding, color: chartBackgroundColor.CGColor)
      layer.insertSublayer(backgroundSegment, atIndex: 0)
      chartBackgroundSegment = backgroundSegment
    }
  }
  
  /**
   Setups `colorPalette` based on `beginColor` and `endColor`. Also setups
   `grayscalePalette`.
   */
  private func setupColorPalettes() {
    
    guard let source = dataSource else {
      return
    }
    
    colorPalette = UIColor.colorRange(
      beginColor: beginColor!,
      endColor: endColor!,
      count: source.numberOfItems()
    )
    
    grayscalePalette = UIColor.colorRange(
      beginColor: inactiveBeginColor,
      endColor: inactiveEndColor,
      count: source.numberOfItems()
    )
  }
  
  /**
   A flag used to distinguish the entry animation (adding elements, clockwise)
   from animation used for individual elements (adding elements, counterclockwise).
   */
  private var initialAnimationComplete = false
  
  /**
   Querries the `dataSource` for data and inserts, removes, or updates all relevant segments.
   
   - parameter animated: specifies whether the operation will be animated, defaults to `true`
   - parameter completion: optional completion block, defaults to `{}`
   */
  final public func reloadData(animated animated: Bool = true, completion: () -> () = {}) {
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
      
      guard let _ = source.item(index) else {
        indexesToRemove.append(index)
        continue
      }
      
      guard let layer = layer(index) else {
        let layer = SegmentLayer(
          frame: self.bounds.largestSquareThatFits(),
          start: source.startAngle(index),
          end: source.endAngle(index),
          lineWidth: lineWidth,
          padding: padding,
          color: colorPalette[index].CGColor
        )
        self.layer.insertSublayer(layer, atIndex: 1)
        chartSegmentLayers.append(layer)
        
        if animated {
          if initialAnimationComplete {
            layer.animateInsertion(
              source.isFullCircle() ? CGFloat(M_PI * 2) : source.startAngle(index),
              endAngle: initialAnimationComplete ? nil : CGFloat(M_PI * 2)
            )
          } else {
            layer.animateInsertion(0, endAngle: source.isFullCircle() ? 0 : CGFloat(M_PI * 2))
          }
        }
        
        continue
      }
      
      layer.startAngle = source.startAngle(index)
      layer.endAngle = source.endAngle(index)
      layer.color = colorPalette[index].CGColor
      layer.lineWidth = lineWidth
      layer.padding = padding
    }
    
    for index in indexesToRemove.reverse() {
      guard let layer = layer(index) else {
        continue
      }
      
      CATransaction.begin()
      CATransaction.setCompletionBlock({
        layer.removeFromSuperlayer()
      })
      
      layer.startAngle = 0
      layer.endAngle = 0
      
      chartSegmentLayers.removeAtIndex(index)
      CATransaction.commit()
    }
    
    initialAnimationComplete = true
    reassignSegmentLayerscapTypes()
    CATransaction.commit()
  }
  
  /**
   Empties the `dataSource` and reloadsData() to clear all segments. Animates changes by default.
   */
  public func empty(animated animated: Bool = true) {
    guard var source = dataSource else {
      return
    }
    source.empty()
    reloadData(animated: animated)
  }
  
  public func animateSegments(color: UIColor?, startAngle: CGFloat?, endAngle: CGFloat?, completion: () -> () = {}) {
    CATransaction.begin()
    CATransaction.setCompletionBlock({
      completion()
    })
    for segment in chartSegmentLayers {
      if let segmentColor = color {
        segment.color = segmentColor.CGColor
      }
      if let segmentStartAngle = startAngle {
        segment.startAngle = segmentStartAngle
      }
      if let segmentEndAngle = endAngle {
        segment.endAngle = segmentEndAngle
      }
    }
    CATransaction.commit()
  }
  
  /**
   A utility function to perform a one-shot animation of a single segment
   that does not need to be based on `dataSource` values.
   You can use it to convey states such as depletion through animation without
   relying on faux `dataSource`.
   
   **Note**: this will remove all segments from your chart but one, you can rely on
   the `completion` closure to reload your data
   
   - parameter color:       `UIColor` used for the segment
   - parameter fromPercent: value between 1-100, representing starting angle
   - parameter duration: duration of the animation
   - parameter completion:  completion, run when segment is removed
   */
  @available(iOS, deprecated=0.2.0, obsoleted=0.3.0, message="The `fromPercent` parameter does not fit nicely into a radian-based environment. Use a substitue with `fromAngle` instead")
  public func animateDepletion(color: UIColor, fromPercent: CGFloat = 100, duration: Double = 1.0, completion: () -> () = {}) {
    animateDepletion(color, fromAngle: fromPercent * 2 * CGFloat(M_PI) / 100, duration: duration, completion: completion)
  }
  
  /**
   A utility function to perform a one-shot animation of a single segment
   that does not need to be based on `dataSource` values.
   You can use it to convey states such as depletion through animation without
   relying on faux `dataSource`.
   
   **Note**: this will remove all segments from your chart but one, you can rely on
   the `completion` closure to reload your data
   
   - parameter color:       `UIColor` used for the segment
   - parameter fromAngle:   a radian value, representing starting angle
   - parameter duration:    duration of the animation
   - parameter completion:  completion, run when segment is removed
   */
  public func animateDepletion(color: UIColor, fromAngle: CGFloat = CGFloat(M_PI), duration: Double = 1.0, completion: () -> () = {}) {
    
    CATransaction.begin()
    CATransaction.setCompletionBlock {
      let segment = SegmentLayer(frame: self.bounds.largestSquareThatFits(), start: 0, end: fromAngle, lineWidth: self.lineWidth, padding: self.padding, color: color.CGColor)
      segment.capType = .BothEnds
      self.layer.addSublayer(segment)
      
      segment.animateRemoval(startAngle: 0, endAngle: 0) {
        completion()
      }
    }
    
    for segment in chartSegmentLayers {
      CATransaction.begin()
      CATransaction.setAnimationDuration(0.25)
      CATransaction.setCompletionBlock({
        segment.removeFromSuperlayer()
        if let index = self.chartSegmentLayers.indexOf(segment) {
          self.chartSegmentLayers.removeAtIndex(index)
        }
      })
      segment.color = color.CGColor
      segment.endAngle = fromAngle
      CATransaction.commit()
    }
    
    CATransaction.commit()
  }
  
  //MARK: - Layer manipulation
  /**
   Loops through the available layers and assigns them appropriate end cap type
   */
  private func reassignSegmentLayerscapTypes() {
    
    guard let source = dataSource else {
      return
    }
    
    for (index, segment) in chartSegmentLayers.enumerate() {
      if source.isFullCircle() {
        segment.capType = .None
      } else {
        switch index {
        case 0 where chartSegmentLayers.count > 1:
          segment.capType = .Begin
        case 0 where chartSegmentLayers.count == 1:
          segment.capType = .BothEnds
        case chartSegmentLayers.count - 1 where chartSegmentLayers.count > 1:
          segment.capType = .End
        default:
          segment.capType = .None
        }
      }
    }
  }
  
  /**
   Returns a `SegmentLayer?` for a given index
   
   - parameter index: Int, index to look at
   - returns: an optional value that's `nil` when index is out of bounds, and
   SegmentLayer when a value is found
   */
  private func layer(index: Int) -> SegmentLayer? {
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
  private func remove(index: Int, startAngle: CGFloat = CGFloat(M_PI * 2), endAngle: CGFloat = CGFloat(M_PI * 2), animated: Bool = true) {
    
    guard let layer = layer(index) else {
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
  public func select(index selectIndex: Int) {
    
    if chartSegmentLayers.count == 0 {
      return
    }
    
    if let _ = layer(selectIndex) {
      switch selectionStyle {
      case .None:
        break
      case .Grow:
        for (index, layer) in chartSegmentLayers.enumerate() {
          layer.selected = index == selectIndex ? !layer.selected : false
          layer.lineWidth = layer.selected ? lineWidth + 10 : lineWidth
          layer.padding = layer.selected ? padding - 10 : padding
        }
      }
    }
  }
  
  func deselect(index: Int) {
    if chartSegmentLayers.count == 0 {
      return
    }
    
    if let layer = layer(index) {
      switch selectionStyle {
      case .None:
        break
      case .Grow:
        layer.selected = false
        layer.lineWidth = lineWidth
        layer.padding = padding
      }
    }
  }
  
  private func selected() -> Int? {
    for (index, layer) in chartSegmentLayers.enumerate() {
      if layer.selected {
        return index
      }
    }
    return nil
  }
  
  override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touch = touches.first,
      let firstLayer = chartSegmentLayers.first else {
        return
    }
    
    let point = firstLayer.convertPoint(touch.locationInView(self), fromLayer: self.layer)
    
    for (index, layer) in chartSegmentLayers.enumerate() {
      if layer.containsPoint(point) {
        if layer.selected {
          deselectHandler(index)
        } else {
          selectHandler(index)
        }
        select(index: index)
        return
      } else {
        if layer.selected {
          deselectHandler(index)
          deselect(index)
        }
      }
    }
  }
  
}

private extension UIColor {
  static func inactiveBeginColor() -> UIColor {
    return UIColor(white: 0.5, alpha: 1.0)
  }
  
  static func inactiveEndColor() -> UIColor {
    return UIColor(white: 0.15, alpha: 1.0)
  }
}