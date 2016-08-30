//
//  main.swift
//  MRLCircleChart
//
//  Created by Marek Lisik on 27/08/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

//  This setup follows Witold Skibniewski and Paul Boot's Swift 2.0 adaptation of
//  Jon Reid's Objective-C approach.
//  Reid's original to be found at http://qualitycoding.org/app-delegate-for-tests/
//  The Swift version comes from Giovanni Lodi's post at
//  http://www.mokacoding.com/blog/prevent-unit-tests-from-loading-app-delegate-in-swift/

import UIKit

private func delegateClassName() -> String? {
  return NSClassFromString("XCTestCase") == nil ? NSStringFromClass(AppDelegate) : nil
}

UIApplicationMain(Process.argc, Process.unsafeArgv, nil, delegateClassName())

