//
//  JournalViewModel.swift
//  My Portfolio
//
//  Created by Никита on 17.03.2022.
//

import Combine
import Foundation

protocol JournalViewModelProtocol: AnyObject {
    var targetCompanyName: String { get set }
    var numberOfStocks: Int { get set }
    var operationDate: Date { get set }
    var currentStockPrice: Decimal { get set }
    var notes: String { get set }
    var cashAmount: Decimal { get set }
    var cashAmountPublisher: Published<Decimal>.Publisher { get }
    var adapter: JournalAdapterProtocol { get }
    func getData()
    func getCashAmount()
    func buyStock(completion: @escaping (StorageError?) -> Void)
    func sellStock(completion: @escaping (StorageError?) -> Void)
    func enrollDividend(completion: @escaping (StorageError?) -> Void)
}

class JournalViewModel: JournalViewModelProtocol {
    
    var adapter: JournalAdapterProtocol
    
    var targetCompanyName: String = ""
    var numberOfStocks: Int = 0
    var operationDate: Date = Date()
    var currentStockPrice: Decimal = 0
    var notes: String = ""
    @Published var cashAmount: Decimal = 0
    var cashAmountPublisher: Published<Decimal>.Publisher { $cashAmount }
    
    func getData() {
        getCashAmount()
    }
    
    func getCashAmount() {
        adapter.getCashAmount { result in
            switch result {
                case .success(let cash):
                    self.cashAmount = cash
                case .failure(let error):
                    print("Error to get cash amount! \(error.localizedDescription)")
            }
        }
    }
    
    func buyStock(completion: @escaping (StorageError?) -> Void) {
        targetCompanyName = targetCompanyName.trimmingCharacters(in: .whitespaces).uppercased()
        adapter.buyStock(companyTicker: targetCompanyName,
                        numberOfStocks: numberOfStocks,
                        timestamp: operationDate,
                        buyingPrice: currentStockPrice,
                        note: notes) { error in
            if let error = error {
                completion(error)
            } else {
                print("buy stock!")
                self.getCashAmount()
                completion(nil)
            }
        }
    }
    
    func sellStock(completion: @escaping (StorageError?) -> Void) {
        targetCompanyName = targetCompanyName.trimmingCharacters(in: .whitespaces).uppercased()
        adapter.sellStocks(companyTicker: targetCompanyName,
                           numberOfStocks: numberOfStocks,
                           sellPrice: currentStockPrice,
                           atDate: operationDate) { result in
            switch result {
                case .success(let profit):
                    print("Value = \(profit)")
                    self.getCashAmount()
                    completion(nil)
                case .failure(let error):
                    completion(error)
            }
        }
    }
    
    func enrollDividend(completion: @escaping (StorageError?) -> Void) {
        targetCompanyName = targetCompanyName.trimmingCharacters(in: .whitespaces).uppercased()
        NetworkingManager().fetchStock(symbol: targetCompanyName) { [weak self] result in
            switch result {
                case .success(_):
                    self?.adapter.enrollDividend(companyTicker: self?.targetCompanyName ?? "",
                                                 amount: self?.currentStockPrice ?? 0,
                                                 date: self?.operationDate ?? Date()) { error in
                        if let error = error {
                            completion(error)
                        } else {
                            print("enroll dividend!")
                            self?.getCashAmount()
                            completion(nil)
                        }
                    }
                case .failure(let error):
                    completion(StorageError.noDataError(message: "No company with symbol \(self?.targetCompanyName ?? "")! \(error.rawValue)"))
            }
        }
        
    }
    
    init(stockBatchGateway: StockBatchGatewayProtocol) {
        self.adapter = JournalAdapter(stockGateway: stockBatchGateway)
        self.adapter.viewModel = self
        self.getCashAmount()
    }
}
