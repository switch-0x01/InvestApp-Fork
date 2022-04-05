//
//  NetworkingManager.swift
//  My Portfolio
//
//  Created by Владислав Седенков on 18.02.2022.
//

import Foundation

public protocol NetworkProtocol: AnyObject {
    
    func fetchStock(
        symbol: String,
        completion: @escaping (Result<Stock, StockError>) -> Void
    )
    
    func fetchIndustry(
        symbol: String,
        completion: @escaping (Result<CompanyDetails, StockError>) -> Void
    )
    
    func fetchData(
        from url: URL,
        completed: @escaping (Result<Data, Error>) -> Void
    )
    
    func fetchDataAvoidingCache(
        from url: URL,
        completed: @escaping (Result<Data, Error>) -> Void
    )
    
    func fetchDataWithOutErrorHandling(
        from url: URL,
        completed: @escaping (Data?) -> Void
    )
    
    func fetchImageData(
        for symbol: String, 
        completion: @escaping (Result<Data, Error>) -> Void
    )
    
    func getToken() -> String
}

public enum StockError: String, Error {
    
    case noData
    case stockError
    case urlError
    case invalidResponse
}

public struct CompanyDetails: Codable {
    let symbol: String?
    let industry: String?
}


final class NetworkingManager: NetworkProtocol {
    
    let cache: NSCache<NSString, NSData> = .init()
    
    func fetchStock(symbol: String, completion: @escaping (Result<Stock, StockError>) -> Void) {
        
        let token = valueForAPIKey(named: "API_CLIENT_ID")
        let urlString = "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?token=\(token)"
        guard let url = URL(string: urlString) else {
            completion(.failure(.urlError))
            return
        }
        // print(url)
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let _ = error {
                completion(.failure(.stockError))
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let result = try decoder.decode(Stock.self, from: data)
                completion(.success(result))
            } catch {
                print(error.localizedDescription)
                completion(.failure(.noData))
            }
        }
        .resume()
    }
    
    func fetchIndustry(
        symbol: String,
        completion: @escaping (Result<CompanyDetails, StockError>) -> Void
    ) {
        
        let token = valueForAPIKey(named: "API_CLIENT_ID")
        let urlString = "https://cloud.iexapis.com/stable/stock/\(symbol)/company?token=\(token)"
        guard let url = URL(string: urlString) else {
            completion(.failure(.urlError))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = error {
                completion(.failure(.stockError))
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let result = try decoder.decode(CompanyDetails.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(StockError.stockError))
            }
        }.resume()
    }
    
    public func fetchData(
        from url: URL,
        completed: @escaping (Result<Data, Error>) -> Void
    ) {
        if let nsdata = cache.object(forKey: url.description as NSString) {
            completed(.success(Data(referencing: nsdata)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard error == nil else {
                completed(.failure(StockError.stockError))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(StockError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(StockError.noData))
                return
            }
            
            self.cache.setObject(NSData(data: data), forKey: url.description as NSString)
            
            completed(.success(data))
        }
        .resume()
    }
    
    public func fetchDataAvoidingCache(
        from url: URL,
        completed: @escaping (Result<Data, Error>) -> Void
    ) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard error == nil else {
                completed(.failure(StockError.stockError))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(StockError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(StockError.noData))
                return
            }
            
            self.cache.setObject(NSData(data: data), forKey: url.description as NSString)
            
            completed(.success(data))
        }
        .resume()
    }
    
    public func fetchDataWithOutErrorHandling(
        from url: URL,
        completed: @escaping (Data?) -> Void
    ) {
        completed(try? Data(contentsOf: url))
    }
    
    func fetchImageData(for symbol: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: "https://storage.googleapis.com/iex/api/logos/\(symbol).png") else {
            return completion(.failure(StockError.urlError))
        }
        
        fetchData(from: url, completed: completion)
    }
    
    private func valueForAPIKey(named keyname: String) -> String {
        guard let filePath = Bundle.main.path(forResource: "ApiKeys", ofType: "plist") else { return "" }
        let plist = NSDictionary(contentsOfFile: filePath)
        let value = plist?.object(forKey: keyname) as? String
        return value ?? ""
    }
    
    func getToken() -> String {
        valueForAPIKey(named: "API_CLIENT_ID")
    }
}
