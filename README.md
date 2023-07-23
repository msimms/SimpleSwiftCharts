# SimpleSwiftCharts
Code for making various charts in Swift; nothing too fancy but it'll do if you just need to add a simple bar or line chart to your app so you can get up and running.

* BarChartView.swift
<p align="center">
<img src="https://github.com/msimms/SimpleSwiftCharts/blob/main/images/bar_chart.jpg?raw=true" alt="Line Graph" width=512/>
</p>

    var splits: Array<Double> = [134.0,149.0,163.0,178.0,193.0]
  	var result: Array<Bar> = []

  	for split in splits {
  		result.append(Bar(value: Double(split), label: Int(split), description: ""))
  	}

    BarChartView(bars: makeSplitGraphBar(splits: mileSplits), color: Color.red, units: "")

* LineGraphView.swift
<p align="center">
<img src="https://github.com/msimms/SimpleSwiftCharts/blob/main/images/line_graph.png?raw=true" alt="Line Graph" width=512/>
</p>

## Building
Just add this repo to your project as a submodule and then add the source files directly to your project in XCode.

## License
This is open source software and is released under the MIT license.
