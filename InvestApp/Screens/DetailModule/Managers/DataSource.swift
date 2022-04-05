//
//  DataSource.swift
//  My Portfolio
//
//  Created by Илья Андреев on 10.03.2022.
//

import Foundation

protocol DataSourcer: AnyObject {
    func fetchModelFor(ticker: String, completion: @escaping (Result<ChartStock, Error>) -> Void)
    func fetchCandlesFor(ticker: String, timeframe: APITimeframe, completion: @escaping (Result<[ChartCandle], Error>) -> Void)
}

class DataSource: DataSourcer {
    private let urlManager: URLManagerable!
    private let networkManager: NetworkProtocol!
    
    init(repository: DependencyRepository) {
        self.urlManager = repository.urlManager
        self.networkManager = repository.networkManager
    }
    
    func fetchModelFor(ticker: String, completion: @escaping (Result<ChartStock, Error>) -> Void) {
        guard let url = urlManager.commonURL(symbol: ticker, queryParams: [:]) else { return }
        networkManager.fetchData(from: url) { result in
            switch result {
            case .success(let data):
                completion(JSONDecoder().decode(from: data))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchCandlesFor(ticker: String, timeframe: APITimeframe, completion: @escaping (Result<[ChartCandle], Error>) -> Void) {
        guard let range: Range = .init(rawValue: timeframe.rawValue),
              let url: URL = urlManager.candlesURL(symbol: "AAPL", range: range, queryParams: [:]) else {
                  return
              }
        
        NetworkingManager().fetchData(from: url) { result in
            switch result {
            case .success(let data):
                completion(JSONDecoder().decode(from: data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
