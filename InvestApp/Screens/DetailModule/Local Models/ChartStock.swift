//
//  ChartStock.swift
//  My Portfolio
//
//  Created by Илья Андреев on 11.03.2022.
//

import Foundation

public struct ChartStock: Codable {
    let change: Double
    let companyName: String
    let currency: String
    let latestPrice: Double
    let open: Double
    let low: Double
    let symbol: String
    
    enum CodingKeys: String, CodingKey {
        case change
        case companyName
        case currency
        case latestPrice
        case open
        case low
        case symbol
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        change = try container.decodeIfPresent(Double.self, forKey: .change) ?? 0.0
        companyName = try container.decodeIfPresent(String.self, forKey: .companyName) ?? " "
        currency = try container.decodeIfPresent(String.self, forKey: .currency) ?? " "
        latestPrice = try container.decodeIfPresent(Double.self, forKey: .latestPrice) ?? 0.0
        open = try container.decodeIfPresent(Double.self, forKey: .open) ?? 0.0
        low = try container.decodeIfPresent(Double.self, forKey: .low) ?? 0.0
        symbol = try container.decodeIfPresent(String.self, forKey: .symbol) ?? " "
    }
}
