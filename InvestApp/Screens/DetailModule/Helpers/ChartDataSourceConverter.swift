//
//  ChartDataSourceConverter.swift
//  My Portfolio
//
//  Created by Eugene Dudkin on 12.03.2022.
//

import Foundation

protocol ChartDataSourceConvertable {
    func scaleDataSource(
        dataSource: [ChartCandle],
        scaleFactor: Int
    ) -> [ChartCandle]
}

class ChartDataSourceConverter: ChartDataSourceConvertable {
    func scaleDataSource(
        dataSource: [ChartCandle],
        scaleFactor: Int
    ) -> [ChartCandle] {
        var targetDataSource = [ChartCandle]()
        let ranges = createRanges(dataSource: dataSource, scaleFactor: scaleFactor)
        
        for range in ranges {
            targetDataSource.append(ChartCandle(
                date: dataSource[range.upperBound].date,
                label: dataSource[range.upperBound].label,
                close: dataSource[range.upperBound].close,
                high: dataSource[range].max()?.high ?? dataSource[range.lowerBound].high,
                low: dataSource[range].min()?.low ?? dataSource[range.upperBound].low,
                open: dataSource[range.lowerBound].open
            ))
        }
        return targetDataSource
    }

    private func createRanges(dataSource: [ChartCandle], scaleFactor: Int) -> [ClosedRange<Int>] {
        var ranges: [ClosedRange<Int>] = []
        for i in stride(from: 0, to: dataSource.count, by: scaleFactor)  {
            let lowerBound = i
            var upperBound = i + scaleFactor - 1
            if upperBound > dataSource.count - 1 {
                upperBound = dataSource.count - 1
            }
            ranges.append(lowerBound...upperBound)
        }
        return ranges
    }
}
