//
//  AnalyticsAdapter.swift
//  My Portfolio
//
//  Created by Сергей Петров on 04.03.2022.
//

import Foundation
import CoreData

// Экран 5 (Аналитика)
protocol AnalyticsAdapterProtocol: AnyObject {
    var companyGateway: CompanyGatewayProtocol { get }
    var portfolioGateway: PortfolioGatewayProtocol { get }
    
    var viewModel: AnalyticsViewModelProtocol? { get set }
    
    func getCashAmount(completion: @escaping (Result<Decimal, StorageError>) -> Void)
    func fetchCompanies(completion: @escaping (Result<[Company], StorageError>) -> Void)
}

class AnalyticsAdapter: NSObject, AnalyticsAdapterProtocol, NSFetchedResultsControllerDelegate {
    
    let companyGateway: CompanyGatewayProtocol
    let portfolioGateway: PortfolioGatewayProtocol
    
    weak var viewModel: AnalyticsViewModelProtocol?
    
    func getCashAmount(completion: @escaping (Result<Decimal, StorageError>) -> Void) {
        portfolioGateway.fetchPortfolio { result in
            switch result {
                case .success(let portfolio):
                    completion(.success(portfolio.cash?.decimalValue ?? 0))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    func fetchCompanies(completion: @escaping (Result<[Company], StorageError>) -> Void) {
        companyGateway.fetchAllCompanies { result in
            switch result {
                case .success(let companies):
                    completion(.success(companies))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        viewModel?.getData()
//        if type == .update {
//            do {
//                try controller.managedObjectContext.save()
//                viewModel?.getData()
//            } catch {
//                print("fail to save context!")
//            }
//        }
    }
    
    init(companyGateway: CompanyGatewayProtocol,
         portfolioGateway: PortfolioGatewayProtocol) {
        self.companyGateway = companyGateway
        self.portfolioGateway = portfolioGateway
        super.init()
        self.companyGateway.fetchedResultsController.delegate = self
        self.portfolioGateway.fetchedResultsController.delegate = self
    }
}
