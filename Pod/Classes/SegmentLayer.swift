//
//  SegmentLayer.swift
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
class SegmentLayer: CALayer {
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
   Constants used by `SegmentLayer`
   */
  struct Constants {
    static let animationDuration = 0.75
  }

  var selected = false

  @NSManaged var startAngle: CGFloat
  @NSManaged var endAngle: CGFloat
  @NSManaged var lineWidth: CGFloat
  @NSManaged var color: CGColorRef
  @NSManaged var padding: CGFloat

  var animationDuration: Double = Constants.animationDuration

  @objc
  enum SegmentCapType: Int {
    case None, Begin, End, BothEnds
  }

  @NSManaged var capType: SegmentCapType

  
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
   Default initialized for `SegmentLayer`, provides all necessary customization
   points.

   - parameter frame:       frame in which to draw the segment. Note that this
   frame should be identical for all chart segments.
   - parameter start:       angle at which to begin drawing
   - parameter end:         angle at which to stop drawing
   - parameter lineWidth:   chart's width
   - parameter color:       `CGColorRef` color of the segment

   - returns: a fully configured `SegmentLayer` instance
   */

  required init(frame: CGRect, start: CGFloat, end: CGFloat, lineWidth: CGFloat, padding: CGFloat = 0, color: CGColorRef) {
    super.init()

    self.frame = frame
    self.startAngle = start
    self.endAngle = end
    self.lineWidth = lineWidth
    self.color = color
    self.padding = padding

    self.commonInit()
  }

  override init(layer: AnyObject) {
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
  private func commonInit() {
    contentsScale = UIScreen.mainScreen().scale
  }

  override func encodeWithCoder(aCoder: NSCoder) {
    super.encodeWithCoder(aCoder)
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
  override func actionForKey(event: String) -> CAAction? {

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

    return super.actionForKey(event)
  }

  /**
   Helper function to generate similar `CAAnimations` easily
   */
  func animation(key: String, toValue: AnyObject?, fromValue: AnyObject) -> CABasicAnimation {
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
  func animationForAngle(key: String) -> CAAction {
    
    var fromValue: AnyObject
    
    if let value = presentationLayer()?.valueForKey(key) {
      fromValue = value
    } else {
      fromValue = CGFloat(M_PI) * 2
    }
    
    return animation(key, toValue:nil, fromValue:fromValue)
  }

  /**
   Provides an animation tailored for the color property.
   */
  func animationForColor() -> CAAction {
    
    var fromValue: AnyObject
    
    if let value = presentationLayer()?.valueForKey(PropertyKeys.colorKey) {
      fromValue = value
    } else {
      fromValue = self.color
    }
    
    return animation(PropertyKeys.colorKey, toValue:nil, fromValue: fromValue)
  }

  /**
   * Animates the removal of the layer from it's `superlayer`. It will run
   * `removeFromSuperlayer` when the animation completes, and provides a
   * `completion` closure that is run after the `removeFromSuperlayer` call.
   */
  func animateRemoval(startAngle exitingStartAngle: CGFloat, endAngle exitingEndAngle: CGFloat, completion: () -> ()) {
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
  func animateInsertion(startAngle: CGFloat, endAngle: CGFloat? = nil) {
    let initialEndAngle = endAngle == nil ? startAngle : endAngle!

    self.addAnimation(animation(PropertyKeys.startAngleKey, toValue: self.startAngle, fromValue: startAngle), forKey: PropertyKeys.startAngleKey)
    self.addAnimation(animation(PropertyKeys.endAngleKey, toValue: self.endAngle, fromValue: initialEndAngle), forKey: PropertyKeys.endAngleKey)
  }

  override class func needsDisplayForKey(key: String) -> Bool {
    if PropertyKeys.needsDisplayProperties.contains(key) {
      return true
    }
    return super.needsDisplayForKey(key)
  }

  //MARK: - Drawing

  override func drawInContext(ctx: CGContext) {
    drawBaseSegment(ctx)
    drawCaps(ctx)
  }

  //MARK: - Hit Testing

  override func containsPoint(point: CGPoint) -> Bool {
    return pathContainsPoint(capPath(startAngle, start: true), point: point)
      || pathContainsPoint(capPath(endAngle, start: false), point: point)
      || pathContainsPoint(baseSegmentPath(), point: point)
  }
}

/**
 Provides SegmentLayer with path-calculations
 */
extension SegmentLayer {
  private func drawBaseSegment(ctx: CGContext) {
    drawPath(ctx, path: baseSegmentPath())
  }

  private func drawCaps(ctx: CGContext) {
    if [.BothEnds, .Begin].contains(capType) {
      drawCap(ctx, angle: startAngle, start: true)
    }

    if [.BothEnds, .End].contains(capType) {
      drawCap(ctx, angle: endAngle, start: false)
    }
  }

  private func drawPath(ctx: CGContext, path: CGPath) {
    CGContextBeginPath(ctx)
    CGContextAddPath(ctx, path)
    CGContextSetFillColorWithColor(ctx, color)
    CGContextDrawPath(ctx, .Fill)
  }

  private func pointOnCircle(center: CGPoint, radius: CGFloat, angle: CGFloat) -> CGPoint {
    return CGPoint(
      x: center.x + radius * cos(angle),
      y: center.y + radius * sin(angle)
    )
  }

  private func drawCap(ctx: CGContext, angle: CGFloat, start: Bool) {
    drawPath(ctx, path: capPath(angle, start: start))
  }

  private func capPath(angle: CGFloat, start: Bool) -> CGPathRef {
    let capRadius = abs(outerRadius - innerRadius) / 2
    let capCenterDistance = outerRadius - capRadius
    let capStartAngle =  CGFloat(M_PI) + angle
    let capEndAngle = CGFloat(M_PI * 2) + angle
    let arcCenter = pointOnCircle(center, radius: capCenterDistance, angle: angle)
    let path = UIBezierPath(
      arcCenter: arcCenter,
      radius: capRadius,
      startAngle: capStartAngle,
      endAngle: capEndAngle,
      clockwise: start
    )

    return path.CGPath
  }

  /**
   Provides a `CGPathRef` that is used for drawing the segment layer as well as for
   hit testing. Radii and angle properties together with layer's bounds are used
   to calculate the path.
   */
  private func baseSegmentPath() -> CGPathRef {

    let center = bounds.center()

    let innerStartPoint = pointOnCircle(center, radius: innerRadius, angle: startAngle)
    let outerStartPoint = pointOnCircle(center, radius: outerRadius, angle: startAngle)
    let innerEndPoint = pointOnCircle(center, radius: innerRadius, angle: endAngle)

    let path = UIBezierPath()

    path.moveToPoint(innerStartPoint)
    path.addLineToPoint(outerStartPoint)
    path.addArcWithCenter(
      center,
      radius: outerRadius,
      startAngle: self.startAngle,
      endAngle: self.endAngle,
      clockwise: true
    )

    path.addLineToPoint(innerEndPoint)
    path.addArcWithCenter(
      center,
      radius: innerRadius,
      startAngle: endAngle,
      endAngle: startAngle,
      clockwise: false
    )

    return path.CGPath
  }

  private func pathContainsPoint(path: CGPathRef, point: CGPoint) -> Bool {
    var transform = CGAffineTransformIdentity
    return withUnsafePointer(&transform, { (pointer: UnsafePointer<CGAffineTransform>) -> Bool in
      CGPathContainsPoint(path, pointer, point, false)
    })
  }
}
