//
//  JournalAdapter.swift
//  My Portfolio
//
//  Created by Сергей Петров on 03.03.2022.
//

import Foundation
import CoreData

// Экран 3 (Дневник сделок)
protocol JournalAdapterProtocol: AnyObject {
    var stockBatchGateway: StockBatchGatewayProtocol { get }
    
    var viewModel: JournalViewModelProtocol? { get set }
    
    func getCashAmount(completion: @escaping (Result<Decimal, StorageError>) -> Void)
    
    func buyStock(companyTicker: String,
                  numberOfStocks: Int,
                  timestamp: Date,
                  buyingPrice: Decimal,
                  note: String?,
                  completion: @escaping (StorageError?) -> Void)
    
    func sellStocks(companyTicker: String, numberOfStocks: Int, sellPrice: Decimal, atDate: Date, completion: @escaping (Result<Decimal, StorageError>) -> Void)
    
    func enrollDividend(companyTicker: String, amount: Decimal, date: Date, completion: @escaping (StorageError?) -> Void)
}

class JournalAdapter: JournalAdapterProtocol {
    let stockBatchGateway: StockBatchGatewayProtocol
    
    weak var viewModel: JournalViewModelProtocol?
    
    func getCashAmount(completion: @escaping (Result<Decimal, StorageError>) -> Void) {
        stockBatchGateway.portfolioGateway.fetchPortfolio { result in
            switch result {
                case .success(let portfolio):
                    completion(.success(portfolio.cash?.decimalValue ?? 0))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    func buyStock(companyTicker: String,
                  numberOfStocks: Int,
                  timestamp: Date,
                  buyingPrice: Decimal,
                  note: String?,
                  completion: @escaping (StorageError?) -> Void) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + timestamp.timeIntervalSinceNow) {
            self.stockBatchGateway.createStockBatch(companyTicker: companyTicker,
                                                    numberOfStocks: numberOfStocks,
                                                    timestamp: timestamp,
                                                    buyingPrice: buyingPrice,
                                                    note: note) { result in
                switch result {
                    case .success(_):
                        completion(nil)
                    case .failure(let error):
                        completion(error)
                }
            }
        }
    }
    
    func sellStocks(companyTicker: String, numberOfStocks: Int, sellPrice: Decimal, atDate: Date, completion: @escaping (Result<Decimal, StorageError>) -> Void) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + atDate.timeIntervalSinceNow) {
            self.stockBatchGateway.sellStocks(companyTicker: companyTicker, numberOfStocks: numberOfStocks, sellPrice: sellPrice) { result in
                switch result {
                    case .success(let profit):
                        completion(.success(profit))
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
        }
    }
    
    func enrollDividend(companyTicker: String, amount: Decimal, date: Date, completion: @escaping (StorageError?) -> Void) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + date.timeIntervalSinceNow) {
            self.stockBatchGateway.fetchAllStockBatches { result in
                switch result {
                    case .success(let stockBatches):
                        let dividendAmount = amount
                        self.stockBatchGateway.portfolioGateway.updatePortfolioCash(cashAmountToAdd: dividendAmount) { result in
                            switch result {
                                case .success(_):
                                    completion(nil)
                                case .failure(let error):
                                    completion(error)
                            }
                        }
                    case .failure(let error):
                        completion(error)
                }
            }
        }
    }
    
    init(stockGateway: StockBatchGatewayProtocol,
         stockBatchFetchControllerDelegate: JournalFetchedResultsDelegate<StockBatch> = JournalFetchedResultsDelegate<StockBatch>()) {
        self.stockBatchGateway = stockGateway
        self.stockBatchGateway.fetchedResultsController.delegate = stockBatchFetchControllerDelegate
    }
}

class JournalFetchedResultsDelegate<Object: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    weak var adapter: JournalAdapterProtocol?
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        self.adapter?.viewModel?.getData()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller.managedObjectContext.hasChanges {
            do {
                try controller.managedObjectContext.save()
            } catch let error {
                print("Fail to save context into \(JournalFetchedResultsDelegate.self); \(error.localizedDescription)")
            }
        }
    }
}
