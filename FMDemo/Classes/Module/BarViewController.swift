//
//  BarViewController.swift
//  FMDemo
//
//  Created by mba on 17/1/19.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit
import Charts

class BarViewController: UIViewController {

    let chartView = BarChartView(frame: CGRect(x: 20, y: 50, width: 300, height: 300))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chartView.delegate = self
        view.addSubview(chartView)

        
        
    }

    func setChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Units Sold")
        // 加上一个界限, 演示图中红色的线
        let jx = ChartLimitLine(limit: 12.0, label: "I am LimitLine")
        chartView.rightAxis.addLimitLine(jx)
        chartView.data = BarChartData(dataSet: chartDataSet)
        // 自定义颜色
        // 例子中有十二个柱状图
//        // colors 是一个数组, 可以给相应的颜色
//        chartDataSet.colors = [UIColor.blueColor(), UIColor.redColor(), UIColor.cyanColor(), UIColor.greenColor(), UIColor.brownColor(), UIColor.purpleColor()]
        // API 自带颜色模板
        //        chartDataSet.colors = ChartColorTemplates.liberty()
//        chartView.animate(yAxisDuration: 1.0, easingOption: .EaseInBounce)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension BarViewController: ChartViewDelegate {
    
}
