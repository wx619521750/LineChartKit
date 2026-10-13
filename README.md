# LineChartKit

`LineChartKit` is a UIKit-based Swift Package containing the reusable line chart implementation from the demo project.

## Add the package

In Xcode, choose **File > Add Package Dependencies...**, click **Add Local...**, and select the `LineChartKit` directory.

Then import the package:

```swift
import LineChartKit
```

## Basic usage

```swift
let chart = LineChartView()
chart.chartModel.lineModel.points = [
    ChartPointModel(x: 0, y: 10),
    ChartPointModel(x: 1, y: 24)
]
chart.reloadData()
```

The package contains `LineChartView`, `ChartModel`, `ChartLineModel`, `ChartPointModel`, the chart style enums, and the `LineChartViewDelegate` callbacks. It does not include the demo app, `SegmentView`, or the Binary Timeline chart.
