//
//  Constants.swift
//  My Portfolio
//
//  Created by Илья Андреев on 03.03.2022.
//

import UIKit

enum NetworkConstants {
    static let token = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "ApiKeys", ofType: "plist")!)!.object(forKey: "API_CLIENT_ID") as! String
    static let baseURL = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "ApiKeys", ofType: "plist")!)!.object(forKey: "BASE_URL") as! String
}

enum Sections: Int, CaseIterable {
    case price
    case account
    
    static let rowsCount: Int = 3
}

enum Mock {
    static let cornerRadius: CGFloat = 10
    static let padding: CGFloat = 20
    static let miniPadding: CGFloat = 5
    static let currentPriceLabelFontSize: CGFloat = 20
    static let changePriceLabelFontSize: CGFloat = 14
    static let chartImageHeight: CGFloat = 340
    static let chartTimeframeSegmentedControlItems: [String] = ["10М", "30М", "1Ч", "Д", "Н", "М"]
    static let periodsSegmentedControlHeight: CGFloat = 30
    static let infoViewHeight: CGFloat = 400
    static let infoViewFontSize: CGFloat = 14
    static let buttonMinimumHeight: CGFloat = 55
    static let actionButtonToWidthMultiplier: CGFloat = 0.43
    static let sellButtonTitle: String = "Продать"
    static let buyButtonTitle: String = "Купить"
    static let buttonTitleTextFontSize: CGFloat = 16
}
