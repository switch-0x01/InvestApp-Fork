//
//  NumberFormatter Extensions.swift
//  My Portfolio
//
//  Created by Алексей Агеев on 11.03.2022.
//

import Foundation

extension NumberFormatter {
    
    /// A formatter that converts between decimal numbers and their textual representations.
    static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        
        return formatter
    }()
    
    /// A formatter that converts between decimal numbers and their textual representations with explicitly shown sign.
    static let signedDecimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        formatter.positivePrefix = "+"
        
        return formatter
    }()
    
    /// A formatter that converts between percent values and their textual representations.
    static let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        formatter.numberStyle = .percent
        
        return formatter
    }()
    
    /// A formatter that converts between percent values and their textual representations with explicitly shown sign.
    static let signedPercentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        formatter.numberStyle = .percent
        formatter.positivePrefix = "+"
        
        return formatter
    }()
    
    /// A formatter that converts between decimal values representing RUB values and their textual representations.
    static let rubFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        formatter.numberStyle = .currency
        formatter.currencyCode = "RUB"
        
        return formatter
    }()
    
    /// A formatter that converts between integer values and their textual representations.
    static let integerFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        formatter.minimumIntegerDigits = 1
        formatter.numberStyle = .decimal
        
        return formatter
    }()
}
