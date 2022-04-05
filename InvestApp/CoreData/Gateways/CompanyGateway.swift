//
//  CompanyGateway.swift
//  My Portfolio
//
//  Created by Сергей Петров on 03.03.2022.
//

import Foundation
import CoreData

protocol CompanyGatewayProtocol {
    typealias CompanyResultController = NSFetchedResultsController<Company>
    var fetchedResultsController: CompanyResultController { get }
    var storageManager: StorageProtocol { get }
    func fetchCompany(companyTicker: String, completion: @escaping (Result<Company, StorageError>) -> Void)
    func fetchAllCompanies(completion: @escaping (Result<[Company], StorageError>) -> Void)
    func createCompany(companyName: String,
                       industry: String,
                       companyTicker: String,
                       currentStockPrice: Decimal,
                       completion: @escaping (Result<Company, StorageError>) -> Void)
    func updateCompany(company: Company,
                       newCompanyName: String?,
                       newIndustry: String?,
                       newCompanyTicker: String?,
                       currentStockPrice: Decimal?,
                       completion: @escaping (Result<Company, StorageError>) -> Void)
    func deleteCompany(company: Company, completion: @escaping (StorageError?) -> Void)
}

class CompanyGateway: CompanyGatewayProtocol {
    
    let storageManager: StorageProtocol
    
    lazy var fetchedResultsController: CompanyResultController = {
        let context = storageManager.mainContext
        let fetchRequest = Company.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "ticker", ascending: true)]
        let controller = CompanyResultController(fetchRequest: fetchRequest,
                                                 managedObjectContext: context,
                                                 sectionNameKeyPath: nil,
                                                 cacheName: nil)
        return controller
    }()
    
    func fetchCompany(companyTicker: String, completion: @escaping (Result<Company, StorageError>) -> Void) {
        fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "ticker == %@", companyTicker)
        do {
            try fetchedResultsController.performFetch()
            if let company = fetchedResultsController.fetchedObjects?.first {
                completion(.success(company))
            } else {
                completion(.failure(StorageError.noDataError(message: "No company for ticker \(companyTicker)!")))
            }
        } catch {
            completion(.failure(StorageError.internalError(message: "Failed to fetch company!")))
        }
        fetchedResultsController.fetchRequest.predicate = nil
    }
    
    func fetchAllCompanies(completion: @escaping (Result<[Company], StorageError>) -> Void) {
        do {
            try fetchedResultsController.performFetch()
            let companies = fetchedResultsController.fetchedObjects ?? []
            completion(.success(companies))
        } catch {
            completion(.failure(StorageError.internalError(message: "Fail to fetch companies!")))
        }
    }
    
    func createCompany(companyName: String,
                       industry: String,
                       companyTicker: String,
                       currentStockPrice: Decimal,
                       completion: @escaping (Result<Company, StorageError>) -> Void) {
        let context = storageManager.mainContext
        let fetchRequest = Company.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "ticker == %@", companyTicker)
        if let company = try? context.fetch(fetchRequest).first {
            completion(.success(company))
        } else {
            let newCompany = Company(entity: Company.entity(), insertInto: context)
            updateCompany(company: newCompany,
                          newCompanyName: companyName,
                          newIndustry: industry,
                          newCompanyTicker: companyTicker,
                          currentStockPrice: currentStockPrice) { result in
                switch result {
                    case .success(let company):
                        completion(.success(company))
                    case .failure(let error):
                        completion(.failure(StorageError.internalError(message: "Can't to save new company! \(error.localizedDescription)")))
                }
            }
        }
    }
    
    func updateCompany(company: Company,
                       newCompanyName: String?,
                       newIndustry: String?,
                       newCompanyTicker: String?,
                       currentStockPrice: Decimal?,
                       completion: @escaping (Result<Company, StorageError>) -> Void) {
        let context = storageManager.mainContext
        company.name = newCompanyName ?? company.name
        company.industry = newIndustry ?? company.industry
        company.ticker = newCompanyTicker ?? company.ticker
        company.currentStockPrice = NSDecimalNumber(decimal: currentStockPrice ?? 0)
        storageManager.saveContext(context: context) { error in
            if let error = error {
                completion(.failure(StorageError.internalError(message: "Can't save company after update! \(error.localizedDescription)")))
            } else {
                completion(.success(company))
            }
        }
    }
    
    func deleteCompany(company: Company, completion: @escaping (StorageError?) -> Void) {
        let context = storageManager.mainContext
        context.delete(company)
        storageManager.saveContext(context: context) { error in
            if let error = error {
                completion(StorageError.internalError(message: "Can't save context after delete company! \(error.localizedDescription)"))
            } else {
                completion(nil)
            }
        }
    }
    
    init(storageManager: StorageProtocol) {
        self.storageManager = storageManager
    }
}
