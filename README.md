# MRLCircleChart

[![CI Status](http://img.shields.io/travis/mlisik/MRLCircleChart.svg?style=flat)](https://travis-ci.org/mlisik/MRLCircleChart)
[![Platform](https://img.shields.io/cocoapods/p/MRLCircleChart.svg?style=flat)](http://cocoapods.org/pods/MRLCircleChart)
[![Version](https://img.shields.io/cocoapods/v/MRLCircleChart.svg?style=flat)](http://cocoapods.org/pods/MRLCircleChart)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Stories in Ready](https://badge.waffle.io/mlisik/MRLCircleChart.png?label=ready&title=Ready)](https://waffle.io/mlisik/MRLCircleChart)
[![License](https://img.shields.io/cocoapods/l/MRLCircleChart.svg?style=flat)](http://cocoapods.org/pods/MRLCircleChart)

![Animated .gif of chart reloading it's data](https://raw.githubusercontent.com/mlisik/MRLCircleChart/master/Screenshots/mrlcirclechart.gif?raw=true "Reloading chart data")

`MRLCircleChart` is a small pie/circle chart UI component written in Swift. Aims to take care of most of the work for you (just pass in a data source and configure the view) at the expense of customizability.

## Main Features

- [x] configuration through a dataSource
- [x] customization through IB
- [x] color, linewidth, begin/end angle animations
- [x] callbacks on selection / deselection

## Usage

### Data setup

`Chart`'s `DataSource` is comprised of an array of `Segment`s and a `maxValue` property that functions as a reference for `Segment`s angle values. You can easily map your source values to `[Segment]`, then initialize a data source conforming to the `MRLCircleChart.DataSource` protocol, and pass this to the `Chart`:

````swift
struct DataSource: MRLCircleChart.DataSource {
  // protocol conformance
}

let segments = [90, 80, 60].map {
  Segment(value: $0, description: "\($0)")
}

chart.dataSource = DataSource(items: segments, maxValue: 250)

````

### Customization

All customization you need can be done via InterfaceBuilder, through the following `IBDesignable` properties:

![InterfaceBuilder's AttributesInspector pane contains a Chart section where primary properties are easily accessible](https://raw.githubusercontent.com/mlisik/MRLCircleChart/master/Screenshots/mrlcirclechart_ib_properties.png?raw=true "Editing Chart properties through InterfaceBuilder")

If you are laying out your `Chart` without IB, these are also readily available.

````swift
@IBInspectable public var lineWidth: CGFloat = 25
@IBInspectable public var padding: CGFloat = 0
@IBInspectable public var chartBackgroundColor: UIColor = UIColor(white: 0.7, alpha: 0.26)
@IBInspectable public var beginColor: UIColor? = UIColor.beginColor()
@IBInspectable public var endColor: UIColor? = UIColor.endColor()
````

### Main public APIs

_See the entire documentation on [Cocoadocs](http://cocoadocs.org/docsets/MRLCircleChart/0.3.5/Classes/Chart.html)._

Beyond customization, the main public APIs revolve around modifying and updating the available data.

#### DataSource

````swift
public mutating func remove(index: Int) -> MRLCircleChart.Segment?
public mutating func insert(item: MRLCircleChart.Segment, index: Int)
public mutating func append(item: MRLCircleChart.Segment)
public mutating func empty()
````

#### Chart

````swift
final public func reloadData(animated animated: Bool = true, completion: () -> () = {})
public func empty(animated animated: Bool = true, color: UIColor? = nil)
public func select(index selectIndex: Int)
public func deselect(index index: Int)
````

#### Callbacks

Two callbacks are available for user interaction events: when a segment is selected and when it's deselected.

````swift
chart.selectHandler = {
  index in print("selected \(index)")
}

chart.deselectHandler = {
  index in print("deselected \(index)")
}
````

## Demo

To run the example project, clone the repo, and run `pod install` from the Example directory first, or run `pod try MRLCircleChart` to check it with a temporary clone.

## Installation

MRLCircleChart is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MRLCircleChart"
```
## Collaboration

If you'd like to help out, check open tickets on [waffle.io](https://waffle.io/mlisik/MRLCircleChart). There's no roadmap for the project yet, but pull requests are welcome (whether you want to clean up, fix or add something), and so are feature requests.

## Author

mlisik, marek.lisik@holdapp.pl

## License

MRLCircleChart is available under the MIT license. See the LICENSE file for more info.
