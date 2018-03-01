//
//  AxisValueFormatter.swift
//  MannFit
//
//  Created by Luis Abraham on 2018-02-28.
//  Copyright © 2018 MannFit Labs. All rights reserved.
//

import UIKit
import Charts

class AxisValueFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    private lazy var xAxisValues = createXAxisValues()
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return xAxisValues[Int(value)]
    }
    
    private func createXAxisValues() -> [String] {
        var twentyFourHourTimes = [String]()
        var twelveHourTimes = [String]()
        
        for i in 0..<24 {
            twentyFourHourTimes.append("\(i)")
        }
        
        for i in twentyFourHourTimes {
            if i == "12" {
                twelveHourTimes.append("NOON")
            } else {
                dateFormatter.dateFormat = "H"
                let hourDate = dateFormatter.date(from: i)!
                
                dateFormatter.dateFormat = "h"
                twelveHourTimes.append(dateFormatter.string(from: hourDate))
            }
        }
        
        return twelveHourTimes
    }
}
