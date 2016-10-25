# Change Log
Sums up significant changes.

---

## [0.5.0](https://github.com/mlisik/MRLCircleChart/releases/tag/0.5.0)
includes: [0.5.0](https://github.com/mlisik/MRLCircleChart/issues?q=milestone%3A0.5.0+is%3Aclosed), [0.4.3](https://github.com/mlisik/MRLCircleChart/issues?q=milestone%3A0.4.3+is%3Aclosed),
[0.4.2](https://github.com/mlisik/MRLCircleChart/issues?q=milestone%3A0.4.2+is%3Aclosed),
[0.4.1](https://github.com/mlisik/MRLCircleChart/issues?q=milestone%3A0.4.1+is%3Aclosed)

##### Adds
- Swift 3.0 support
- tests for `UIColor.colorRange()`
- tests through FBSnapshotTestCase

##### Fixes
- fixes `UIColor.colorRange()` incorrect color generation

## [0.4.0](https://github.com/mlisik/MRLCircleChart/releases/tag/0.4.0)
includes [0.4.0](https://github.com/mlisik/MRLCircleChart/issues?q=milestone%3A0.4.0+is%3Aclosed),
[0.3.3](https://github.com/mlisik/MRLCircleChart/issues?q=milestone%3A0.3.3+is%3Aclosed)

##### Adds
- improved README and example app
- closures for segment selection (in place of delegate callbacks)
- means of notifying subscribers when segment has been deselected

## [0.3.0](https://github.com/mlisik/MRLCircleChart/releases/tag/0.3.0)
[issue list](https://github.com/mlisik/MRLCircleChart/issues?q=milestone%3A0.3.0+is%3Aclosed),


##### Adds
- manual segment selection

## [0.2.0](https://github.com/mlisik/MRLCircleChart/releases/tag/0.2.0)
[issue list](https://github.com/mlisik/MRLCircleChart/issues?q=milestone%3A0.4.0+is%3Aclosed)

##### Adds
- Swift Package Manager support
- Carthage support
- completion closure on `ChartView.reloadData()`
- means of emptying the chart easily

##### Fixes
- incorrect caps with only a single segment
- depletion always starting at 2PI instead of current end angle
- hit testing ignoring caps

## [0.1.0](https://github.com/mlisik/MRLCircleChart/releases/tag/0.2.0)
[issue list](https://github.com/mlisik/MRLCircleChart/issues?q=milestone%3A0.4.0+is%3Aclosed)

Initial release, with basic functionality in place.
