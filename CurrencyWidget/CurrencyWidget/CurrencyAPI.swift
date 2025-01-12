//
//  CurrencyAPI.swift
//  CurrencyWidget
//
//  Created by Arkadiy Schneider on 12.01.2025.
//

import Foundation

struct CurrencyRate: Codable {
    let base: String
    let rates: [String: Double]
}

class CurrencyAPI {
    static let shared = CurrencyAPI()
    private let baseURL = "https://api.exchangerate-api.com/v4/latest/"
    private let session = URLSession.shared

    func fetchRates(for baseCurrency: String, completion: @escaping (Result<CurrencyRate, Error>) -> Void) {
        let url = URL(string: "\(baseURL)\(baseCurrency)")!
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            do {
                let rates = try JSONDecoder().decode(CurrencyRate.self, from: data)
                completion(.success(rates))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
