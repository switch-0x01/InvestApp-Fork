//
//  Stock.swift
//  My Portfolio
//
//  Created by Владислав Седенков on 18.02.2022.
//

import Foundation


import Foundation


public struct Stock: Codable {
    
    let avgTotalVolume: Int?
    let calculationPrice: String?
    let change: Double?
    let changePercent: Double?
    let close: Double?
    let closeSource: String?
    let closeTime: Int?
    let companyName: String?
    let currency: String?
    let delayedPrice: Double?
    let delayedPriceTime: Int?
    let extendedChange: Double?
    let extendedChangePercent: Double?
    let extendedPrice: Double?
    let extendedPriceTime: Int?
    let high: Double?
    let highSource: String?
    let highTime: Int?
    let iexAskPrice: Double?
    let iexAskSize: Int?
    let iexBidPrice: Double?
    let iexBidSize: Int?
    let iexClose: Double?
    let iexCloseTime: Int?
    let iexLastUpdated: Int?
    let iexMarketPercent: Double?
    let iexOpen: Double?
    let iexOpenTime: Int?
    let iexRealtimePrice: Double?
    let iexRealtimeSize: Int?
    let iexVolume: Int?
    let lastTradeTime: Int?
    let latestPrice: Double?
    let latestSource: String?
    let latestTime: String?
    let latestUpdate: Int?
    let latestVolume: Int?
    let low: Double?
    let lowSource: String?
    let lowTime: Int?
    let marketCap: Int?
    let oddLotDelayedPrice: Double?
    let oddLotDelayedPriceTime: Int?
    let open: Double?
    let openTime: Int?
    let openSource: String?
    let peRatio: Double?
    let previousClose: Double?
    let previousVolume: Int?
    let primaryExchange: String?
    let symbol: String?
    let volume: Int?
    let week52High: Double?
    let week52Low: Double?
    let ytdChange: Double?
    let isUSMarketOpen: Bool?
}
