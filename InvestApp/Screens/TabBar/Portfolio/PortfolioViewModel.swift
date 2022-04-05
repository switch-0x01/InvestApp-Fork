//
//  PortfolioViewModel.swift
//  My Portfolio
//
//  Created by Алексей Агеев on 11.03.2022.
//

import Foundation
import Combine

class PortfolioViewModel: NSObject, ObservableObject, DependencyHolder {
    let model = PortfolioModel()
    private var modelSubscription: AnyCancellable!
    
    var _repository: DependencyRepository?
    
    var portfolioWorth: Decimal {
        model.portfolioWorth
    }
    
    var sharpe: Decimal {
        model.sharpe
    }
    
    var beta: Decimal {
        model.beta
    }
    
    var cash: Decimal {
        model.cash
    }
    
    var companies: [PortfolioModel.PortfolioCompany] {
        model.companies
    }
    
    func companyImageData(ticker: String) async -> Data {
        await model.companyImageData(ticker: ticker)
    }
    
    override init() {
        super.init()
        modelSubscription = model.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func dependencyInjected() {
        injectDependency(to: model)
    }
    
    func ticker(for row: Int) -> String {
        model.companies[row].ticker
    }
}
