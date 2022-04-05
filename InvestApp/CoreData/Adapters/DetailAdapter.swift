//
//  DetailAdapter.swift
//  My Portfolio
//
//  Created by Сергей Петров on 12.03.2022.
//

import Foundation
import CoreData

protocol DetailViewModelProtocol: AnyObject {
    func getDelta()
    func getStocksNum()
    func getSumValue()
}

protocol DetailAdapterProtocol: AnyObject {
    var companyGateway: CompanyGateway { get }
    
    var viewModel: DetailViewModelProtocol? { get set }
    
    func getDelta(companyTicker: String, completion: @escaping(Result<Decimal, StorageError>) -> Void)
    func getStocksNum(companyTicker: String, completion: @escaping(Result<Int, StorageError>) -> Void)
    func getSumValue(companyTicker: String, completion: @escaping(Result<Decimal, StorageError>) -> Void)
}

class DetailAdapter: DetailAdapterProtocol {
    let companyGateway: CompanyGateway
    
    weak var viewModel: DetailViewModelProtocol?
    
    init(companyGateway: CompanyGateway,
         companyFetchControllerDelegate: DetailFetchedResultsDelegate<Company> = DetailFetchedResultsDelegate<Company>()) {
        self.companyGateway = companyGateway
        self.companyGateway.fetchedResultsController.delegate = companyFetchControllerDelegate
    }
    
    func getDelta(companyTicker: String, completion: @escaping (Result<Decimal, StorageError>) -> Void) {
        companyGateway.fetchCompany(companyTicker: companyTicker) { result in
            switch result {
                case .success(let company):
                    let currentSum = company.stockBatches?.reduce(into: Decimal(0)) { partialResult, stockBatch in
                        if let stockBatch = stockBatch as? StockBatch {
                            partialResult += Decimal(stockBatch.numberOfStocks) * (company.currentStockPrice?.decimalValue ?? 0)
                        }
                    } ?? 0
                    let buyingSum = company.stockBatches?.reduce(into: Decimal(0)) { partialResult, stockBatch in
                        if let stockBatch = stockBatch as? StockBatch {
                            partialResult += Decimal(stockBatch.numberOfStocks) * (stockBatch.buyingPrice?.decimalValue ?? 0)
                        }
                    } ?? 0
                    completion(.success(currentSum - buyingSum))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    func getStocksNum(companyTicker: String, completion: @escaping (Result<Int, StorageError>) -> Void) {
        companyGateway.fetchCompany(companyTicker: companyTicker) { result in
            switch result {
                case .success(let company):
                    let numberOfStocks = company.stockBatches?.reduce(into: 0) { $0 += ($1 as? StockBatch)?.numberOfStocks ?? 0 } ?? 0
                    completion(.success(Int(numberOfStocks)))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    func getSumValue(companyTicker: String, completion: @escaping (Result<Decimal, StorageError>) -> Void) {
        companyGateway.fetchCompany(companyTicker: companyTicker) { result in
            switch result {
                case .success(let company):
                    let currentSum = company.stockBatches?.reduce(into: Decimal(0)) { partialResult, stockBatch in
                        if let stockBatch = stockBatch as? StockBatch {
                            partialResult += Decimal(stockBatch.numberOfStocks) * (company.currentStockPrice?.decimalValue ?? 0)
                        }
                    }
                    completion(.success(currentSum ?? 0))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
}

class DetailFetchedResultsDelegate<Object: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    weak var adapter: DetailAdapterProtocol?
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        self.adapter?.viewModel?.getDelta()
        self.adapter?.viewModel?.getSumValue()
        self.adapter?.viewModel?.getStocksNum()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller.managedObjectContext.hasChanges {
            do {
                try controller.managedObjectContext.save()
            } catch let error {
                print("Fail to save context into \(DetailFetchedResultsDelegate.self); \(error.localizedDescription)")
            }
        }
    }
}
