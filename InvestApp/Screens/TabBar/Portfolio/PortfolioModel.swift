//
//  PortfolioModel.swift
//  My Portfolio
//
//  Created by Алексей Агеев on 11.03.2022.
//

import Foundation
import Combine

class PortfolioModel: PortfolioModelProtocol, DependencyHolder, ObservableObject {
    struct PortfolioCompany {
        let name: String                  // Company's name (Core Data)
        let ticker: String                // Company's ticker (Core Data)
        let numberOfStocks: Int64         // Number of stocks of that company (Core Data)
        var stockPrice: Decimal? = nil    // Stock price (API)
        var change: Decimal? = nil        // Stock price change (API)
        var changePercent: Decimal? = nil // Stock price change in percents (API)
        var share: Decimal? = nil         // Company's share in portfolio (Evaluated by model)
        
        init(name: String,
             ticker: String,
             numberOfStocks: Int64,
             stockPrice: Decimal? = nil,
             change: Decimal? = nil,
             changePercent: Decimal? = nil,
             share: Decimal? = nil
        ) {
            self.name = name
            self.ticker = ticker
            self.numberOfStocks = numberOfStocks
            self.stockPrice = stockPrice
            self.change = change
            self.changePercent = changePercent
            self.share = share
        }
        
        init(company: Company, stock: Stock?) {
            self.name = stock?.companyName ?? (company.name ?? (stock?.symbol ?? (company.ticker ?? "No name")))
            self.ticker = stock?.symbol ?? company.ticker ?? "No ticker"
            if let stockBatches = company.stockBatches?.allObjects as? [StockBatch] {

                self.numberOfStocks = stockBatches.reduce(0 as Int64) { nextPartialResult, stockBatch in
                    return nextPartialResult + stockBatch.numberOfStocks
                }
            } else {
                self.numberOfStocks = 0
            }
            
            if let latestPrice = stock?.latestPrice {
                self.stockPrice = Decimal(latestPrice)
            } else {
                self.stockPrice = company.currentStockPrice?.decimalValue
            }

            if let change = stock?.change {
                self.change = Decimal(change)
            }
            
            if let changePercent = stock?.changePercent {
                self.changePercent = Decimal(changePercent)
            }
        }
        
        mutating func priceChanged(to newPrice: Decimal, inPercent: Decimal) {
            self.change = newPrice
            self.changePercent = inPercent
        }
    }
    
    weak var _repository: DependencyRepository?
    
    private(set) var portfolioWorth: Decimal = 0
    private(set) var sharpe: Decimal = 0
    private(set) var beta: Decimal = 0
    private(set) var cash: Decimal = 0
    private(set) var companies = [PortfolioCompany]()
    
    var adapter: PortfolioAdapterProtocol?
    
    func dependencyInjected() {
        adapter = PortfolioAdapter(stockBatchGateway: stockBatchGateway)
        adapter?.model = self
        reloadData()
    }
    
    func reloadData() {
        getData()
        getCashAmount()
        getPortfolioPrice()
        objectWillChange.send()
    }
    
    func getData() {
        adapter?.fetchCompanies { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(fetchedCompanies):
                Task {
                    self.companies = await self.adaptCompanies(from: fetchedCompanies)
                    self.objectWillChange.send()
                }
            }
        }
    }
    
    private func fetchStock(symbol: String) async -> Stock? {
        return await withCheckedContinuation { continuation in
            self.repository?.networkManager.fetchStock(symbol: symbol) { result in
                switch result {
                case .success(let stock):
                    continuation.resume(returning: stock)
                case .failure(_):
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    private func adaptCompanies(from fetchedCompanies: [Company]) async -> [PortfolioCompany] {
        var portfolioCompanies = await withTaskGroup(of: PortfolioCompany.self, returning: [PortfolioCompany].self) { group in
            for fetchedCompany in fetchedCompanies {
                guard let ticker = fetchedCompany.ticker else {
                    continue
                }
                
                group.addTask {
                    let loadedStock = await self.fetchStock(symbol: ticker)
                    return PortfolioCompany(company: fetchedCompany, stock: loadedStock) // \.share is nil!
                }
            }
            
            return await group.reduce(into: [PortfolioCompany]()) { $0.append($1) }
        }
        
        portfolioWorth = portfolioCompanies.reduce(0) { result, company -> Decimal in
            result + (company.stockPrice ?? 0) * Decimal(company.numberOfStocks)
        }
        
        for (index, company) in portfolioCompanies.enumerated() {
            portfolioCompanies[index].share = (company.stockPrice ?? 0) * Decimal(company.numberOfStocks) / portfolioWorth
        }
        
        return portfolioCompanies.sorted { $0.share ?? 0 > $1.share ?? 0 }
    }
    
    func getCashAmount() {
        adapter?.getCashAmount { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(fetchedCash):
                self.cash = fetchedCash
            }
        }
    }
    
    func getPortfolioPrice() {
        adapter?.fetchPortfolioPrice { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(fetchedPrice):
                self.portfolioWorth = fetchedPrice
            }
        }
    }
    
    func companyImageData(ticker: String) async -> Data {
        return await withCheckedContinuation { continuation in
            repository?.networkManager.fetchImageData(for: ticker) { result in
                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    print(error.localizedDescription)
                    continuation.resume(returning: Data())
                }
            }
        }
    }
}
