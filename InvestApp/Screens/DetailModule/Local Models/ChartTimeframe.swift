//
//  ChartRange.swift
//  My Portfolio
//
//  Created by Eugene Dudkin on 12.03.2022.
//

import Foundation

enum ChartTimeframe: Int, CaseIterable {
    case tenMinutes // APITimeframe = 10 min, ChartTimeframe = 10 min, scaleFactor = 1
    case thirtyMinutes // APITimeframe = 30 min, ChartTimeframe = 30 min, scaleFactor = 1
    case oneHour // APITimeframe = 30 min, ChartTimeframe = 1 hour, scaleFactor = 2
    case oneDay // APITimeframe = 1 day, ChartTimeframe = 1 day, scaleFactor = 1
    case oneWeek // APITimeframe = 1 day, ChartTimeframe = 1 day, scaleFactor = 5
    case oneMonth // APITimeframe = 1 day, ChartTimeframe = 1 month, scaleFactor = 21
}
