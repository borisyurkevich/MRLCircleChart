//
//  UIColorRangeTestCase.swift
//  MRLCircleChart
//
//  Created by Marek Lisik on 26/09/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

import Quick
import Nimble

@testable import MRLCircleChart

class UIColorRangeSpec: QuickSpec {
  override func spec() {
    describe("UIColor") {
      context("when given black and white") {
        
        let black = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        let white = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        context("when requested a two-piece array") {
          let array = UIColor.colorRange(beginColor: black, endColor: white, count: 2)
          
          it("contains only perfect black and perfect white") {
            expect(array.count).to(equal(2))
            expect(array).to(equal([black, white]))
          }
        }
        
        context("when requested a three-piece array") {
          let array = UIColor.colorRange(beginColor: black, endColor: white, count: 3)
          
          it("contains perfect black, a mid-grey and a perfect white") {
            expect(array.count).to(equal(3))
            expect(array).to(equal([
              black,
              UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1),
              white]
            ))
          }
        }
      }
      
      context("when given white and black") {
        let white = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        let black = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        context("when requested a three-piece array") {
          let array = UIColor.colorRange(beginColor: white, endColor: black, count: 3)
          it("contains perfect black, a mid-grey and a perfect white") {
            expect(array.count).to(equal(3))
            expect(array).to(equal([
              white,
              UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1),
              black]
            ))
          }
        }
      }
      
      context("when given red and blue") {
        let red = UIColor.red
        let blue = UIColor.blue
        
        context("when requested a three-piece array") {
          let array = UIColor.colorRange(beginColor: red, endColor: blue, count: 3)
          
          it("contains perfect red, purple and blue") {
            expect(array.count).to(equal(3))
            expect(array).to(equal([
              red,
              UIColor(red: 0.5, green: 0, blue: 0.5, alpha: 1),
              blue
            ]))
          }
        }
        
        context("when requested an five-piece array") {

          let array = UIColor.colorRange(beginColor: red, endColor: blue, count: 5)
        
          it("contains the correct range of colors") {
            expect(array.count).to(equal(5))
            expect(array).to(equal([
              UIColor(red: 1.0, green: 0, blue: 0.0, alpha: 1),
              UIColor(red: 0.75, green: 0, blue: 0.25, alpha: 1),
              UIColor(red: 0.5, green: 0, blue: 0.5, alpha: 1),
              UIColor(red: 0.25, green: 0, blue: 0.75, alpha: 1),
              UIColor(red: 0.0, green: 0, blue: 1.0, alpha: 1)]
            ))
          }
        }
      }
    }
  }
}
