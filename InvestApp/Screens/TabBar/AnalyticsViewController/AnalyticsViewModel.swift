//
//  AnalyticsViewModel.swift
//  My Portfolio
//
//  Created by Сергей Петров on 04.03.2022.
//

import Foundation
import UIKit

let storageManager = StorageManager()
let portfolioGateway = PortfolioGateway(storageManager: storageManager)
let companyGateway = CompanyGateway(storageManager: storageManager)
let stockBatchGateway = StockBatchGateway(storageManager: storageManager,
                                          portfolioGateway: portfolioGateway,
                                          companyGateway: companyGateway)

protocol AnalyticsViewModelProtocol: AnyObject {
    var dataPublisher: Published<[Company]>.Publisher { get }
    var cashPublisher: Published<Decimal>.Publisher { get }
    var dataColorsPublisher: Published<[UIColor]>.Publisher { get }
    var adapter: AnalyticsAdapterProtocol? { get set }
    func getData()
    func getCashAmount()
    func getColors() -> [UIColor]
}

class AnalyticsViewModel: AnalyticsViewModelProtocol {
    var adapter: AnalyticsAdapterProtocol?
    
    @Published var data: [Company] = []
    @Published var cash: Decimal = 0
    @Published var dataColors: [UIColor] = [.systemRed, .systemGreen, .systemBlue, .systemBrown, .systemPink, .systemGray2, .systemOrange, .systemPurple]
    var dataPublisher: Published<[Company]>.Publisher { $data }
    var cashPublisher: Published<Decimal>.Publisher { $cash }
    var dataColorsPublisher: Published<[UIColor]>.Publisher { $dataColors }
    
    func getData() {
        adapter?.fetchCompanies { result in
            switch result {
                case .success(let companies):
                    self.data = companies
                case .failure(let error):
                    print("Fail to fetch companies, \(error.localizedDescription)")
            }
        }
    }
    
    func getCashAmount() {
        adapter?.getCashAmount{ result in
            switch result {
                case .success(let cash):
                    self.cash = cash
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    func getColors() -> [UIColor] {
        return dataColors
    }
    
    init(portfolioGateway: PortfolioGatewayProtocol, companyGateway: CompanyGatewayProtocol) {
        self.adapter = AnalyticsAdapter(companyGateway: companyGateway, portfolioGateway: portfolioGateway)
        adapter?.viewModel = self
        getData()
        getCashAmount()
    }
}
