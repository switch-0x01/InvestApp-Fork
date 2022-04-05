//
//  URLManager.swift
//  My Portfolio
//
//  Created by Илья Андреев on 05.03.2022.
//

import Foundation

public protocol URLManagerable: AnyObject {
    
    func candlesURL(symbol: String, range: Range, queryParams: [String: String]) -> URL?
    func commonURL(symbol: String, queryParams: [String: String]) -> URL?
}

public final class URLManager: URLManagerable {
    private let token: String!
    private let baseURL: String!
    
    init(token: String, baseURL: String) {
        self.token = token
        self.baseURL = baseURL
    }
    
    public func candlesURL(symbol: String, range: Range, queryParams: [String : String] = [:]) -> URL? {
        var urlString = baseURL + symbol + "/chart/" + range.rawValue
        var queryItems = [URLQueryItem]()
        
        for (name, value) in queryParams{
            queryItems.append(.init(name: name, value: value))
        }
        
        queryItems.append(.init(name: "token", value: token))
        
        urlString += "?" + queryItems.map{"\($0.name)=\($0.value ?? "")"}.joined(separator: "&")
        return URL(string: urlString)
    }
    
    public func commonURL(symbol: String, queryParams: [String : String] = [:]) -> URL? {
        var urlString = baseURL + symbol + "/quote"
        var queryItems = [URLQueryItem]()
        
        for (name, value) in queryParams{
            queryItems.append(.init(name: name, value: value))
        }
        
        queryItems.append(.init(name: "token", value: token))
        
        urlString += "?" + queryItems.map{"\($0.name)=\($0.value ?? "")"}.joined(separator: "&")
        return URL(string: urlString)
    }
}

public enum Range: String, CaseIterable {
    case none = ""
    case max
    case fiveYears = "5y"
    case twoYears = "2y"
    case oneYear = "1y"
    case yearToDate = "ytd"
    case sixMonths = "6m"
    case threeMonths = "3m"
    case oneMonth = "1m"
    case oneMonthIn30MinutesIntervals = "1mm"
    case fiveDays = "5d"
    case fiveDaysIn10MinutesIntervals = "5dm"
    case date
    case dynamic
}

enum APITimeframe: String {
    case tenMinutes = "5dm"
    case thirtyMinutes = "1mm"
    case oneDay = "max" //"5d" "1m" "3m" "6m" "ytd" "1y" "2y" "5y" "max"
}

