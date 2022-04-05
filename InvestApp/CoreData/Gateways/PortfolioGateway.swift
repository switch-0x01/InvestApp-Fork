//
//  PortfolioGateway.swift
//  My Portfolio
//
//  Created by Сергей Петров on 03.03.2022.
//

import Foundation
import CoreData

protocol PortfolioGatewayProtocol {
    typealias PortfolioResultController = NSFetchedResultsController<Portfolio>
    var storageManager: StorageProtocol { get }
    var fetchedResultsController: PortfolioResultController { get }
    func fetchPortfolio(completion: @escaping (Result<Portfolio, StorageError>) -> Void)
    func createPortfolio(cashAmount: Decimal, completion: @escaping (Result<Portfolio, StorageError>) -> Void)
    func updatePortfolioCash(cashAmountToAdd: Decimal, completion: @escaping(Result<Portfolio, StorageError>) -> Void)
    func deletePortfolio(completion: @escaping (StorageError?) -> Void)
}

class PortfolioGateway: PortfolioGatewayProtocol {
    
    let storageManager: StorageProtocol
    
    lazy var fetchedResultsController: PortfolioResultController = {
        let context = storageManager.mainContext
        let fetchRequest = Portfolio.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "cash", ascending: false)]
        let controller = PortfolioResultController(fetchRequest: fetchRequest,
                                                   managedObjectContext: context,
                                                   sectionNameKeyPath: nil,
                                                   cacheName: nil)
        return controller
    }()
    
    func fetchPortfolio(completion: @escaping (Result<Portfolio, StorageError>) -> Void) {
        do {
            try fetchedResultsController.performFetch()
            if let portfolio = fetchedResultsController.fetchedObjects?.first {
                completion(.success(portfolio))
            } else {
                createPortfolio(cashAmount: 0) { result in
                    switch result {
                        case .success(let portfolio):
                            completion(.success(portfolio))
                        case .failure(_):
                            completion(.failure(StorageError.noDataError(message: "No portfolio!")))
                    }
                }
                
            }
        } catch {
            completion(.failure(StorageError.internalError(message: "Fail to fetch portfolio!")))
        }
    }
    
    func createPortfolio(cashAmount: Decimal, completion: @escaping (Result<Portfolio, StorageError>) -> Void) {
        let context = storageManager.mainContext
        let fetchRequest = Portfolio.fetchRequest()
        if let portfolio = try? context.fetch(fetchRequest).first {
            completion(.success(portfolio))
        } else {
            if let entity = NSEntityDescription.entity(forEntityName: "Portfolio", in: context) {
                let newPortfolio = Portfolio(entity: entity, insertInto: context)
                newPortfolio.cash = NSDecimalNumber(decimal: cashAmount)
                storageManager.saveContext(context: context) { error in
                    if let error = error {
                        completion(.failure(StorageError.internalError(message: "Fail to create portfolio! \(error.localizedDescription)")))
                    } else {
                        completion(.success(newPortfolio))
                    }
                }
            } else {
                completion(.failure(StorageError.noDataError(message: "No entity for portfolio!")))
            }
        }
    }
    
    func updatePortfolioCash(cashAmountToAdd: Decimal, completion: @escaping (Result<Portfolio, StorageError>) -> Void) {
        let context = storageManager.mainContext
        let fetcRequest = Portfolio.fetchRequest()
        guard let portfolio = try? context.fetch(fetcRequest).first, portfolio.cash != nil else {
            createPortfolio(cashAmount: cashAmountToAdd) { result in
                switch result {
                    case .success(let portfolio):
                        completion(.success(portfolio))
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
            return
        }
        portfolio.cash = portfolio.cash?.adding(NSDecimalNumber(decimal: cashAmountToAdd))
        if (portfolio.cash?.decimalValue ?? 0) < 0 {
            context.reset()
            completion(.failure(StorageError.notEnoughCash(message: "Not enought cash to buy stocks! Current cash amount = \(portfolio.cash?.decimalValue ?? 0), buying price = \(abs(cashAmountToAdd))")))
        }
        storageManager.saveContext(context: context) { error in
            if let error = error {
                completion(.failure(StorageError.internalError(message: "Can't to update company! \(error.localizedDescription)")))
            } else {
                completion(.success(portfolio))
            }
        }
    }
    
    func deletePortfolio(completion: @escaping (StorageError?) -> Void) {
        let context = storageManager.mainContext
        let deleteRequest = Portfolio.fetchRequest()
        if let portfolio = try? context.fetch(deleteRequest).first {
            context.delete(portfolio)
        }
        storageManager.saveContext(context: context) { error in
            if let error = error {
                completion(StorageError.internalError(message: "Can't save context after delete portfolio! \(error.localizedDescription)"))
            } else {
                completion(nil)
            }
        }
    }
    
    init(storageManager: StorageProtocol) {
        self.storageManager = storageManager
    }
}
