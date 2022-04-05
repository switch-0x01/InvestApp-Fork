//
//  URL + Ext.swift
//  My Portfolio
//
//  Created by Илья Андреев on 05.03.2022.
//

import Foundation

extension URL: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: StaticString) {
        self.init(string: "\(value)")!
    }
}
