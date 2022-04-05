//
//  ChartCandle + Ext.swift
//  My Portfolio
//
//  Created by Eugene Dudkin on 03.03.2022.
//

import Foundation

extension ChartCandle: Comparable {
    
    static func < (lhs: ChartCandle, rhs: ChartCandle) -> Bool {
        lhs.close < rhs.close
    }
    
    static func == (lhs: ChartCandle, rhs: ChartCandle) -> Bool {
        lhs.close == rhs.close
    }
}
