//
//  PortfolioAdapter.swift
//  My Portfolio
//
//  Created by Сергей Петров on 03.03.2022.
//

import Foundation
import CoreData

protocol PortfolioModelProtocol: AnyObject {
    func getData()
    func getCashAmount()
    func getPortfolioPrice()
}

// Экран 2 (Портфель)
protocol PortfolioAdapterProtocol: AnyObject {
    var stockBatchGateway: StockBatchGatewayProtocol { get }
    var model: PortfolioModelProtocol? { get set }
    
    func getCashAmount(completion: @escaping (Result<Decimal, StorageError>) -> Void)
    
    func fetchPortfolioPrice(completion: @escaping (Result<Decimal, StorageError>) -> Void)
    
    func fetchCompanies(completion: @escaping (Result<[Company], StorageError>) -> Void)
}

class PortfolioAdapter: NSObject, PortfolioAdapterProtocol {
    
    var stockBatchGateway: StockBatchGatewayProtocol
    weak var model: PortfolioModelProtocol?
    var portfolioFetchedResultsDelegate: PortfolioFetchedResultsDelegate<Portfolio>
    var companyFetchControllerDelegate: PortfolioFetchedResultsDelegate<Company>
    var stockBatchFetchControllerDelegate: PortfolioFetchedResultsDelegate<StockBatch>
    
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
    
    func fetchPortfolioPrice(completion: @escaping (Result<Decimal, StorageError>) -> Void) {
        stockBatchGateway.fetchAllStockBatches { result in
            switch result {
                case .success(let stockBatches):
                    let sumPrice: Decimal = stockBatches.reduce(into: Decimal(0)) { $0 += Decimal($1.numberOfStocks) * ($1.company?.currentStockPrice?.decimalValue ?? 0) }
                    completion(.success(sumPrice))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    func fetchCompanies(completion: @escaping (Result<[Company], StorageError>) -> Void) {
        stockBatchGateway.companyGateway.fetchAllCompanies { result in
            switch result {
                case .success(let companies):
                    completion(.success(companies))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    init(stockBatchGateway: StockBatchGatewayProtocol,
         portfolioFetchControllerDelegate: PortfolioFetchedResultsDelegate<Portfolio> = PortfolioFetchedResultsDelegate<Portfolio>(),
         companyFetchControllerDelegate: PortfolioFetchedResultsDelegate<Company> = PortfolioFetchedResultsDelegate<Company>(),
         stockBatchFetchControllerDelegate: PortfolioFetchedResultsDelegate<StockBatch> = PortfolioFetchedResultsDelegate<StockBatch>()) {
        self.stockBatchGateway = stockBatchGateway
        // сохраняю сильную ссылку на делегаты
        self.portfolioFetchedResultsDelegate  = portfolioFetchControllerDelegate
        self.companyFetchControllerDelegate = companyFetchControllerDelegate
        self.stockBatchFetchControllerDelegate = stockBatchFetchControllerDelegate
        // передаю делегаты в контроллеры
        self.stockBatchGateway.portfolioGateway.fetchedResultsController.delegate = portfolioFetchControllerDelegate
        self.stockBatchGateway.companyGateway.fetchedResultsController.delegate = companyFetchControllerDelegate
        self.stockBatchGateway.fetchedResultsController.delegate = stockBatchFetchControllerDelegate

        super.init()
        // назначаю адаптер делегатам
        portfolioFetchControllerDelegate.adapter = self
        companyFetchControllerDelegate.adapter = self
        stockBatchFetchControllerDelegate.adapter = self
    }
}


class PortfolioFetchedResultsDelegate<Object: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    weak var adapter: PortfolioAdapterProtocol?
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            self.adapter?.model?.getCashAmount()
            self.adapter?.model?.getPortfolioPrice()
            self.adapter?.model?.getData()
    }
}
