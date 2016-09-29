//
//  main.swift
//  MRLCircleChart
//
//  Created by Marek Lisik on 29/09/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

private func delegateClassName() -> String? {
  return NSClassFromString("XCTestCase") == nil ? NSStringFromClass(AppDelegate.self) : nil
}

UIApplicationMain(CommandLine.argc, UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory( to: UnsafeMutablePointer<Int8>.self, capacity: Int(CommandLine.argc)), nil, delegateClassName())
