//
//  Extensions.swift
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

extension CGRect {
  func center() -> CGPoint {
    return CGPoint(x: size.width / 2, y: size.height / 2)
  }
  
  func largestSquareThatFits() -> CGRect {
    let squareSide = min(size.width, size.height)
    let vertical = size.height > size.width
    let origin = CGPoint(
      x: vertical ? 0 : (size.width - squareSide) / 2,
      y: !vertical ? 0 : (size.height - squareSide) / 2
    )
    return CGRect(origin: origin, size: CGSize(width: squareSide, height: squareSide))
  }
}

struct HSBComponents {
  var h: CGFloat
  var s: CGFloat
  var b: CGFloat
  var a: CGFloat
}

extension UIColor {
  /**
   Calculates a range of colours between `beginColour` and `endColour` with
   number of steps equal to `count` and steps distributed evenly.
   
   - parameter beginColor: first colour in the returned `Array`
   - parameter endColor:   final colour in the returned `Array`
   - parameter count:      number of colours in the returned `Array`
   
   - returns: `[UIColor]` with number of items equal to `count`, containing a
   'gradient' of colour values between `beginColor` and `endColor`
   */
  class func colorRange(beginColor beginColor: UIColor, endColor: UIColor, count: Int) -> [UIColor] {
    
    guard count > 0 else {
      return []
    }

    guard count > 1 else {
      return [beginColor]
    }

    var count = count - 1
    
    var br: CGFloat = 0
    var bg: CGFloat = 0
    var bb: CGFloat = 0
    var ba: CGFloat = 0
    
    beginColor.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
    
    var er: CGFloat = 0
    var eg: CGFloat = 0
    var eb: CGFloat = 0
    var ea: CGFloat = 0
    
    endColor.getRed(&er, green: &eg, blue: &eb, alpha: &ea)
    
    var result: [UIColor] = []

    for index in 0...count {
      
        func component(begin: CGFloat, end: CGFloat, index: Int) -> CGFloat {
          return begin - (begin - end) / CGFloat(count) * CGFloat(index)
        }
        
        let red = component(br, end: er, index: index)
        let green = component(bg, end: eg, index: index)
        let blue = component(bb, end: eb, index: index)
        let alpha = component(ba, end: ea, index: index)
        
        let color = UIColor(red:red, green:green, blue:blue, alpha:alpha)
        
        result.append(color)

    }
    
    return result
  }
  
  func desaturated() -> UIColor {
    var components = self.getHSBComponents()
    components.s = 0
    return UIColor.fromHSBComponents(components)
  }
  
  func getHSBComponents() -> HSBComponents {
    var components = HSBComponents(h: 0, s: 0, b: 0, a: 0)
    self.getHue(
      &components.h,
      saturation: &components.s,
      brightness: &components.b,
      alpha: &components.a
    )
    return components
  }
  
  static func fromHSBComponents(components: HSBComponents) -> UIColor {
    return UIColor(
      hue: components.h,
      saturation: components.s,
      brightness: components.b,
      alpha: components.a
    )
  }
}

extension NSCoder {
  /**
   Encodes `ref` and associates it with four different keys, one per each
   colour component (red, green, blue, alpha), with key names based on the
   provided `key` such as: red component is encoded under `"\(key)_red"` key and
   so on.
   */
  func encodeCGColorRef(ref: CGColorRef, key: NSString) {
    self.encodeFloat(Float(CGColorGetComponents(ref)[0]), forKey: "\(key)_red")
    self.encodeFloat(Float(CGColorGetComponents(ref)[1]), forKey: "\(key)_green")
    self.encodeFloat(Float(CGColorGetComponents(ref)[2]), forKey: "\(key)_blue")
    self.encodeFloat(Float(CGColorGetComponents(ref)[3]), forKey: "\(key)_alpha")
  }
  /**
   Decodes and returns a `CGColorRef` whose four color components were
   previously encoded under keys derived from the given `key` such as red
   component was encoded under `"\(key)_red"` key and so on.
   
   - returns: CGColorRef recontructed for a given `key`
   */
  func decodeCGColorRefForKey(key: NSString) -> CGColorRef {
    let red = CGFloat(self.decodeFloatForKey("\(key)_red"))
    let green = CGFloat(self.decodeFloatForKey("\(key)_green"))
    let blue = CGFloat(self.decodeFloatForKey("\(key)_blue"))
    let alpha = CGFloat(self.decodeFloatForKey("\(key)_alpha"))
    
    return UIColor(red: red, green: green, blue: blue, alpha: alpha).CGColor
  }
}

extension CGPoint {
  /**
   Calculates a midpoint located between the two given points, `lhs` and `rhs`. Sequence of
   arguments given is unimportant.
   
   - returns: CGPoint calculated by averaging given points.
   */
  static func midPoint(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(
      x: round((lhs.x + rhs.x) / 2),
      y: round((lhs.y + rhs.y) / 2)
    )
  }
}
