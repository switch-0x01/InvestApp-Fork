//
//  JSONDecoder + Ext.swift
//  My Portfolio
//
//  Created by Илья Андреев on 17.03.2022.
//

import Foundation

extension JSONDecoder {
    func decode<W: Decodable>(from data: Data) -> Result<W, Error> {
        do {
            let result = try decode(W.self, from: data)
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
}
