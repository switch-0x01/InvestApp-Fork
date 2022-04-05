//
//  DependencyRepository.swift
//  My Portfolio
//
//  Created by Евгений on 16.02.2022.
//

import Foundation

class DependencyRepository {
    let logger = SimpleLogger()
    let networkManager: NetworkProtocol = NetworkingManager()
    let urlManager: URLManagerable = URLManager(token: "Tpk_ab5ee41d45174cf3b3a842406df3af0b", baseURL: NetworkConstants.baseURL)
}
