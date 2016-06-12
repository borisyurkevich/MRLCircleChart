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

/*
 * Provides keys for easy access to Chart properties
 */
private enum ChartProperties {
  static let dataSourceKey = "dataSource"
  static let maxAngleKey = "maxAngle"
  static let lineWidthKey = "lineWidth"
}

/**
 Chart is a `UIView` subclass that provides a graphical representation
 of it's data source in the form of a pie chart. It manages an array of
 SegmentLayers that draw each segment of the chart individually, and relies
 on it's data source for relaying values (also angle values) for each layer.
 */
@objc
public class Chart: UIView {

  //MARK: - Public variables

  public var dataSource: DataSource?
  public var delegate: Delegate?
  public var selectionStyle: SegmentSelectionStyle = .DesaturateNonSelected

  //MARK: - Public Inspectables

  @IBInspectable public var lineWidth: CGFloat = 25
  @IBInspectable public var padding: CGFloat = 0
  @IBInspectable public var chartBackgroundColor: UIColor = UIColor(white: 0.7, alpha: 0.66)
  @IBInspectable public var beginColor: UIColor?
  @IBInspectable public var endColor: UIColor?
  @IBInspectable public var inactiveBeginColor = UIColor.inactiveBeginColor()
  @IBInspectable public var inactiveEndColor = UIColor.inactiveEndColor()
  
  //MARK: - Private variables

  private let chartContainer = UIView()
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
    self.setupChartContainerIfNeeded()
  }

  //MARK: - Setup

  /**
   Calculates the view that will hold individual `SegmentLayers` as well as
   the square frame for that view, in such a way that it fills the most of the
   available frame.

   This is also used to resize the container appropriately with bounds changes,
   as well as for the intial configuration of `outerRadiusRatio` and `innerRadiusRatio`.
   */
  private func setupChartContainerIfNeeded() {

    let squareSide = min(frame.size.width, frame.size.height)
    let squaredBounds = CGRect(origin: CGPointZero, size: CGSize(width: squareSide, height: squareSide))

    if chartContainer.superview == nil {
      chartContainer.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
      addSubview(chartContainer)
    }

    chartContainer.bounds = squaredBounds
    chartContainer.center = bounds.center()
    
    if let backgroundSegment = chartBackgroundSegment {
      backgroundSegment.frame = chartContainer.bounds
    } else {
      chartBackgroundSegment = SegmentLayer(frame: chartContainer.bounds, start: 0, end: CGFloat(M_PI * 2), lineWidth: lineWidth, padding: padding, color: chartBackgroundColor.CGColor)
      chartContainer.layer.insertSublayer(chartBackgroundSegment!, atIndex:0)
    }

    for layer in chartSegmentLayers {
      layer.frame = chartContainer.bounds
      layer.position = chartContainer.bounds.center()
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
    setupChartContainerIfNeeded()

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
          frame: chartContainer.bounds,
          start: source.startAngle(index),
          end: source.endAngle(index),
          lineWidth: lineWidth,
          padding: padding,
          color: colorPalette[index].CGColor
        )
        chartContainer.layer.addSublayer(layer)
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
      let segment = SegmentLayer(frame: self.chartContainer.bounds, start: 0, end: fromAngle, lineWidth: self.lineWidth, padding: self.padding, color: color.CGColor)
      segment.capType = .BothEnds
      self.chartContainer.layer.addSublayer(segment)
      
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

  override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touch = touches.first,
          let source = dataSource else {
      return
    }

    guard source.numberOfItems() > 0 else {
      return
    }

    let point = self.convertPoint(touch.locationInView(self), toCoordinateSpace: chartContainer)

    for (index, layer) in chartSegmentLayers.enumerate() {
      if layer.containsPoint(point) {
        guard let del = delegate else {
          break
        }
        del.chartDidSelectItem(index)
      }
    }

    switch selectionStyle {
    case .None:
      break
    case .Grow:
      for layer in chartSegmentLayers {
        layer.selected = layer.containsPoint(point) ? !layer.selected : false
        layer.lineWidth = layer.selected ? lineWidth + 20 : lineWidth
        layer.padding = layer.selected ? padding - 20 : padding
      }
      break
    case .DesaturateNonSelected:
      var select = false

      for layer in chartSegmentLayers {
        layer.selected = layer.containsPoint(point) ? !layer.selected : false
      }

      for layer in chartSegmentLayers {
        if layer.selected {
          select = layer.selected
          break
        }
      }

      for (index, layer) in chartSegmentLayers.enumerate() {
        if select {
          layer.color = layer.containsPoint(point) ? colorPalette[index].CGColor : grayscalePalette[index].CGColor
        } else {
          layer.color = colorPalette[index].CGColor
        }
      }
      break
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