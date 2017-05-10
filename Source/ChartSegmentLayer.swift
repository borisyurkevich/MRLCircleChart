//
//  ChartSegmentLayer.swift
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
 `CALayer` subclass used by the chart view to draw the individual segments of
 it's pie chart. This class is only used internally.
 */
class ChartSegmentLayer: CALayer {
  /**
   Defines the keys for encodeable properties of the layer. Also, exposes
   `animatableProperties`, an array of keys for properties that require custom
   animations.
   */
  struct PropertyKeys {
    static let startAngleKey = "startAngle"
    static let endAngleKey = "endAngle"
    static let lineWidthKey = "lineWidth"
    static let colorKey = "color"
    static let capType = "capType"
    static let boundsKey = "bounds"
    static let paddingKey = "padding"
    
    static let animatableProperties = [
      colorKey, startAngleKey, endAngleKey, lineWidthKey, paddingKey
    ]
    
    static let needsDisplayProperties = [
      startAngleKey, endAngleKey, lineWidthKey, colorKey, capType, boundsKey, paddingKey
    ]
  }
  /**
   Constants used by `ChartSegmentLayer`
   */
  struct Constants {
    static let animationDuration = 0.75
  }
  
  var selected = false
  
  @NSManaged var startAngle: CGFloat
  @NSManaged var endAngle: CGFloat
  @NSManaged var lineWidth: CGFloat
  @NSManaged var color: CGColor
  @NSManaged var padding: CGFloat
  
  var animationDuration: Double = Constants.animationDuration
  
  @objc
  enum ChartSegmentCapType: Int {
    case none, begin, end, bothEnds
  }
  
  @NSManaged var capType: ChartSegmentCapType
  
  //MARK: - Computed Properties
  
  var outerRadius: CGFloat {
    return bounds.width / 2 - padding
  }
  
  var innerRadius: CGFloat {
    return outerRadius - lineWidth
  }
  
  var center: CGPoint {
    return bounds.center()
  }
  
  /**
   Default initialized for `ChartSegmentLayer`, provides all necessary customization
   points.
   
   - parameter frame:       frame in which to draw the segment. Note that this
   frame should be identical for all chart segments.
   - parameter start:       angle at which to begin drawing
   - parameter end:         angle at which to stop drawing
   - parameter lineWidth:   chart's width
   - parameter color:       `CGColorRef` color of the segment
   
   - returns: a fully configured `ChartSegmentLayer` instance
   */
  
  required init(frame: CGRect, start: CGFloat, end: CGFloat, lineWidth: CGFloat, padding: CGFloat = 0, color: CGColor) {
    super.init()
    
    self.frame = frame
    self.startAngle = start
    self.endAngle = end
    self.lineWidth = lineWidth
    self.color = color
    self.padding = padding
    
    self.commonInit()
  }
  
  override init(layer: Any) {
    super.init(layer: layer)
    self.commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.commonInit()
  }
  
  /**
   Common initialization point, to be used for any operation that are common
   to all initializers and can be performed after `self` is available.
   */
  fileprivate func commonInit() {
    contentsScale = UIScreen.main.scale
    transform = CATransform3DMakeRotation(-.pi / 2, 0, 0, 1)
  }
  
  override func encode(with aCoder: NSCoder) {
    super.encode(with: aCoder)
  }
  
  //MARK: - Animation Overrides
  /**
   Overrides `CALayer`'s `actionForKey(_:)` method to specify animation
   behaviour for custom properties.
   Currently returns an animation action only for keys defined in
   `PropertyKeys.animatableProperties` `Array`.
   
   - parameter event: String corresponding to the property key
   
   - returns: a custom animation for specified properties
   */
  override func action(forKey event: String) -> CAAction? {
    
    if superlayer == nil {
      return nil
    }
    
    let shouldSkipAnimationOnEntry = superlayer == nil
      && (PropertyKeys.lineWidthKey == event || PropertyKeys.paddingKey == event)
    
    if event == PropertyKeys.colorKey {
      return animationForColor()
    }
    
    outer: if PropertyKeys.animatableProperties.contains(event) {
      if shouldSkipAnimationOnEntry {
        break outer
      }
      return animationForAngle(event)
    }
    
    return super.action(forKey: event)
  }
  
  /**
   Helper function to generate similar `CAAnimations` easily
   */
  func animation(_ key: String, toValue: AnyObject?, fromValue: AnyObject) -> CABasicAnimation {
    let animation = CABasicAnimation(keyPath: key)
    animation.duration = animationDuration
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    animation.toValue = toValue
    animation.fromValue = fromValue
    
    return animation
  }
  
  /**
   Provides an animation tailored for the start- and endAngle properties.
   */
  func animationForAngle(_ key: String) -> CAAction {
    
    var fromValue: AnyObject = (2 * CGFloat.pi) as AnyObject
    
    if let value = presentation()?.value(forKey: key) {
      fromValue = value as AnyObject
    } else {
      if let value = value(forKey: key) {
        fromValue = value as AnyObject
      }
    }
    
    return animation(key, toValue:nil, fromValue:fromValue)
  }
  
  /**
   Provides an animation tailored for the color property.
   */
  func animationForColor() -> CAAction {
    
    var fromValue: AnyObject = self.color
    
    if let value = presentation()?.value(forKey: PropertyKeys.colorKey) {
      fromValue = value as AnyObject
    }
    
    return animation(PropertyKeys.colorKey, toValue:nil, fromValue: fromValue)
  }
  
  /**
   * Animates the removal of the layer from it's `superlayer`. It will run
   * `removeFromSuperlayer` when the animation completes, and provides a
   * `completion` closure that is run after the `removeFromSuperlayer` call.
   */
  func animateRemoval(startAngle exitingStartAngle: CGFloat, endAngle exitingEndAngle: CGFloat, completion: @escaping () -> ()) {
    CATransaction.begin()
    CATransaction.setCompletionBlock({
      self.removeFromSuperlayer()
      completion()
    })
    
    self.startAngle = exitingStartAngle
    self.endAngle = exitingEndAngle
    
    CATransaction.commit()
  }
  
  /**
   * Animates the insertion of the layer, given an initial `startAngle` and,
   * optionally, an initial `endAngle` (defaults to startAngle).
   */
  func animateInsertion(_ startAngle: CGFloat, endAngle: CGFloat? = nil, animated: Bool = true) {
    let initialEndAngle = endAngle == nil ? startAngle : endAngle!
    
    CATransaction.begin()
    CATransaction.setAnimationDuration(animated ? animationDuration : 0)
    self.add(animation(PropertyKeys.startAngleKey, toValue: self.startAngle as AnyObject?, fromValue: startAngle as AnyObject), forKey: PropertyKeys.startAngleKey)
    self.add(animation(PropertyKeys.endAngleKey, toValue: self.endAngle as AnyObject?, fromValue: initialEndAngle as AnyObject), forKey: PropertyKeys.endAngleKey)
    
    CATransaction.commit()
  }
  
  override class func needsDisplay(forKey key: String) -> Bool {
    if PropertyKeys.needsDisplayProperties.contains(key) {
      return true
    }
    return super.needsDisplay(forKey: key)
  }
  
  //MARK: - Drawing
  
  override func draw(in ctx: CGContext) {
    drawBaseSegment(in: ctx)
    drawCaps(in: ctx)
  }
  
  //MARK: - Hit Testing
  
  override func contains(_ point: CGPoint) -> Bool {
    return ([.bothEnds, .begin].contains(capType) && capPath(startAngle, start: true).contains(point))
      || ([.bothEnds, .end].contains(capType) && capPath(endAngle, start: false).contains(point))
      || baseSegmentPath().contains(point)
  }
}

/**
 Provides ChartSegmentLayer with path-calculations
 */
extension ChartSegmentLayer {
  fileprivate func drawBaseSegment(in ctx: CGContext) {
    drawPath(in: ctx, path: baseSegmentPath())
  }
  
  fileprivate func drawCaps(in ctx: CGContext) {
    if [.bothEnds, .begin].contains(capType) {
      drawCap(in: ctx, angle: startAngle, start: true)
    }
    
    if [.bothEnds, .end].contains(capType) {
      drawCap(in: ctx, angle: endAngle, start: false)
    }
  }
  
  fileprivate func drawPath(in ctx: CGContext, path: CGPath) {
    ctx.beginPath()
    ctx.addPath(path)
    ctx.setFillColor(color)
    ctx.drawPath(using: .fill)
  }
  
  fileprivate func pointOnCircle(_ center: CGPoint, radius: CGFloat, angle: CGFloat) -> CGPoint {
    return CGPoint(
      x: center.x + radius * cos(angle),
      y: center.y + radius * sin(angle)
    )
  }
  
  fileprivate func drawCap(in ctx: CGContext, angle: CGFloat, start: Bool) {
    drawPath(in: ctx, path: capPath(angle, start: start))
  }
  
  /**
   Provides path for either begin or end cap
   
   - parameter angle: angle at which to attach the cap
   - parameter start: determines the `clockwise` parameter for path drawing, pass `true` if adding cap to the beggining of the base segment
   
   - returns: path for drawing the defined cap
   */
  fileprivate func capPath(_ angle: CGFloat, start: Bool) -> CGPath {
    let capRadius = abs(outerRadius - innerRadius) / 2
    let capCenterDistance = outerRadius - capRadius
    let capStartAngle =  .pi + angle
    let capEndAngle = .pi * 2 + angle
    let arcCenter = pointOnCircle(center, radius: capCenterDistance, angle: angle)
    let path = UIBezierPath(
      arcCenter: arcCenter,
      radius: capRadius,
      startAngle: capStartAngle,
      endAngle: capEndAngle,
      clockwise: start
    )
    
    return path.cgPath
  }
  
  /**
   Provides a `CGPathRef` that is used for drawing the segment layer as well as for
   hit testing. Radii and angle properties together with layer's bounds are used
   to calculate the path.
   */
  fileprivate func baseSegmentPath() -> CGPath {
    
    let center = bounds.center()
    
    let innerStartPoint = pointOnCircle(center, radius: innerRadius, angle: startAngle)
    let outerStartPoint = pointOnCircle(center, radius: outerRadius, angle: startAngle)
    let innerEndPoint = pointOnCircle(center, radius: innerRadius, angle: endAngle)
    
    let path = UIBezierPath()
    
    path.move(to: innerStartPoint)
    path.addLine(to: outerStartPoint)
    path.addArc(
      withCenter: center,
      radius: outerRadius,
      startAngle: self.startAngle,
      endAngle: self.endAngle,
      clockwise: true
    )
    
    path.addLine(to: innerEndPoint)
    path.addArc(
      withCenter: center,
      radius: innerRadius,
      startAngle: endAngle,
      endAngle: startAngle,
      clockwise: false
    )
    
    return path.cgPath
  }
}
