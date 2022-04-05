//
//  StockBatchAdapter.swift
//  My Portfolio
//
//  Created by Сергей Петров on 03.03.2022.
//

import Foundation
import CoreData

protocol StockBatchGatewayProtocol {
    typealias StockBatchResultController = NSFetchedResultsController<StockBatch>
    var storageManager: StorageProtocol { get }
    var portfolioGateway: PortfolioGatewayProtocol { get }
    var companyGateway: CompanyGatewayProtocol { get }
    var fetchedResultsController: StockBatchResultController { get }
    func fetchAllStockBatches(completion: @escaping (Result<[StockBatch], StorageError>) -> Void)
    func createStockBatch(companyTicker: String,
                          numberOfStocks: Int,
                          timestamp: Date,
                          buyingPrice: Decimal,
                          note: String?,
                          completion: @escaping (Result<StockBatch, StorageError>) -> Void)
    func sellStocks(companyTicker: String,
                    numberOfStocks: Int,
                    sellPrice: Decimal,
                    completion: @escaping (Result<Decimal, StorageError>) -> Void)
}

class StockBatchGateway: StockBatchGatewayProtocol {
    
    let storageManager: StorageProtocol
    let portfolioGateway: PortfolioGatewayProtocol
    let companyGateway: CompanyGatewayProtocol
    
    lazy var fetchedResultsController: StockBatchResultController = {
        let context = storageManager.mainContext
        let fetchRequest = StockBatch.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        let controller = StockBatchResultController(fetchRequest: fetchRequest,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        return controller
    }()
    
    func fetchAllStockBatches(completion: @escaping (Result<[StockBatch], StorageError>) -> Void) {
        do {
            try fetchedResultsController.performFetch()
            let stockBatches = fetchedResultsController.fetchedObjects ?? []
            completion(.success(stockBatches))
        } catch {
            completion(.failure(StorageError.internalError(message: "Fail to fetch all StockBatches!")))
        }
    }
    
    func createStockBatch(companyTicker: String,
                          numberOfStocks: Int,
                          timestamp: Date,
                          buyingPrice: Decimal,
                          note: String?,
                          completion: @escaping (Result<StockBatch, StorageError>) -> Void) {
        let context = storageManager.mainContext
        
        let networkManager = NetworkingManager()
        networkManager.fetchStock(symbol: companyTicker) { [weak self] result in
            switch result {
                case .success(let stock):
                    guard let fetchedCompanyName = stock.companyName, !fetchedCompanyName.isEmpty else {
                        completion(.failure(StorageError.noDataError(message: "No company with ticker \(companyTicker)")))
                        return
                    }
                    var buyingSum = buyingPrice * Decimal(numberOfStocks)
                    var currentPortfolio: Portfolio?
                    self?.portfolioGateway.fetchPortfolio { result in
                        switch result {
                            case .success(let portfolio):
                                currentPortfolio = portfolio
                            case .failure(let error):
                                completion(.failure(StorageError.noDataError(message: "No portfolio with title!, \(error.localizedDescription)")))
                        }
                    }
                    if (currentPortfolio?.cash?.decimalValue ?? 0) < buyingSum {
                        completion(.failure(StorageError.notEnoughCash(message: "Not enought cash to buy \(numberOfStocks) stock(s) of \(companyTicker)!")))
                        return
                    }
                    networkManager.fetchIndustry(symbol: companyTicker) { [weak self] result in
                        switch result {
                            case .success(let stock2):
                                let industry = stock2.industry ?? "Unknown"
                                var currentCompany: Company?
                                self?.companyGateway.createCompany(companyName: stock.companyName ?? companyTicker,
                                                                   industry: industry,
                                                                   companyTicker: companyTicker,
                                                                   currentStockPrice: NSDecimalNumber(value: stock.latestPrice ?? 0).decimalValue) { result in
                                    switch result {
                                        case .success(let company):
                                            currentCompany = company
                                        case .failure(let error):
                                            print("Fail to create company with symbol \(companyTicker), \(error.localizedDescription)")
                                    }
                                }
                                guard let currentCompany = currentCompany else {
                                    completion(.failure(StorageError.noDataError(message: "No company with symbol \(companyTicker)")))
                                    return
                                }
                                
                                if let currentPortfolio = currentPortfolio {
                                    if (currentPortfolio.cash?.decimalValue ?? 0) < buyingSum {
                                        completion(.failure(StorageError.notEnoughCash(message: "Not enought cash to buy \(numberOfStocks) stock(s) of \(companyTicker)!")))
                                    } else {
                                        let newStockBatch = StockBatch(entity: StockBatch.entity(), insertInto: context)
                                        newStockBatch.numberOfStocks = Int64(numberOfStocks)
                                        newStockBatch.buyingPrice = NSDecimalNumber(decimal: buyingPrice)
                                        newStockBatch.note = note
                                        newStockBatch.company = currentCompany
                                        newStockBatch.portfolio = currentPortfolio
                                        self?.portfolioGateway.updatePortfolioCash(cashAmountToAdd: -buyingSum) { result in
                                            switch result {
                                                case .success(_):
                                                    completion(.success(newStockBatch))
                                                case .failure(let error):
                                                    context.reset()
                                                    completion(.failure(error))
                                            }
                                        }
                                    }
                                } else {
                                    context.reset()
                                    completion(.failure(StorageError.internalError(message: "Can't fetch portfolio!")))
                                }
                            case .failure(let error):
                                completion(.failure(StorageError.noDataError(message: "No company with ticker \(companyTicker)! \(error.rawValue)")))
                        }
                    }
                case .failure(let error):
                    completion(.failure(StorageError.noDataError(message: "No company with ticker \(companyTicker)! \(error.rawValue)")))
            }
        }
    }
    
    func sellStocks(companyTicker: String, numberOfStocks: Int, sellPrice: Decimal, completion: @escaping (Result<Decimal, StorageError>) -> Void) {
        let context = storageManager.mainContext
        var profit: Decimal = 0
        var incomingCash: Decimal = 0
        companyGateway.fetchCompany(companyTicker: companyTicker) { result in
            switch result {
                case .success(let company):
                    let allStocksNumber = company.stockBatches?.compactMap { $0 as? StockBatch }.reduce(into: Decimal(0)) { $0 += Decimal($1.numberOfStocks) } ?? 0
                    if allStocksNumber < Decimal(numberOfStocks) {
                        completion(.failure(StorageError.noDataError(message: "Too many stocks to sell!")))
                        return
                    } else if allStocksNumber == Decimal(numberOfStocks) {
                        let stockBatches = company.stockBatches?.compactMap { $0 as? StockBatch } ?? []
                        stockBatches.forEach { stockBatch in
                            profit += Decimal(stockBatch.numberOfStocks) * (sellPrice - (stockBatch.buyingPrice?.decimalValue ?? 0))
                            incomingCash += Decimal(stockBatch.numberOfStocks) * sellPrice
                        }
                        self.companyGateway.deleteCompany(company: company) { error in
                            if let error = error {
                                profit = 0
                                completion(.failure(error))
                            }
                        }
                    } else {
                        var currentNumberOfStocks = Int64(numberOfStocks)
                        let stockBatches = company.stockBatches?.compactMap { $0 as? StockBatch } ?? []
                        for stockBatch in stockBatches.sorted(by: { stockBatch1, stockBatch2 in
                            if let timestamp1 = stockBatch1.timestamp,
                               let timestamp2 = stockBatch2.timestamp {
                                return timestamp1 < timestamp2
                            }
                            return false
                        }) {
                            if stockBatch.numberOfStocks < currentNumberOfStocks {
                                currentNumberOfStocks -= stockBatch.numberOfStocks
                                profit += (Decimal(stockBatch.numberOfStocks) * (sellPrice - (stockBatch.buyingPrice?.decimalValue ?? 0)))
                                incomingCash += Decimal(stockBatch.numberOfStocks) * sellPrice
                                context.delete(stockBatch)
                            } else {
                                let tmp = stockBatch.numberOfStocks
                                stockBatch.numberOfStocks = stockBatch.numberOfStocks - currentNumberOfStocks
                                profit += (Decimal(tmp - stockBatch.numberOfStocks) * (sellPrice - (stockBatch.buyingPrice?.decimalValue ?? 0)))
                                incomingCash += Decimal(tmp - stockBatch.numberOfStocks) * sellPrice
                                currentNumberOfStocks = 0
                                break
                            }
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
            }
        }
        
        do {
            self.portfolioGateway.updatePortfolioCash(cashAmountToAdd: incomingCash) { result in
                switch result {
                    case .success(_):
                        completion(.success(profit))
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
            try context.save()
        } catch let error {
            completion(.failure(StorageError.internalError(message: "Can't save context after delete stock! \(error.localizedDescription)")))
        }
    }
    
    init(storageManager: StorageProtocol, portfolioGateway: PortfolioGatewayProtocol, companyGateway: CompanyGatewayProtocol) {
        self.storageManager = storageManager
        self.portfolioGateway = portfolioGateway
        self.companyGateway = companyGateway
    }
}
