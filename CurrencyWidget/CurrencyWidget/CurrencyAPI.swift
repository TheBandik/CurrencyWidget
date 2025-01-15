//
//  CurrencyAPI.swift
//  CurrencyWidget
//
//  Created by Arkadiy Schneider on 12.01.2025.
//

import Foundation

struct CurrenciesListResponse: Decodable {
    let data: [String: Currency]
}

struct Currency: Decodable {
    let symbol: String
    let name: String
    let symbol_native: String
    let decimal_digits: Int
    let rounding: Int
    let code: String
    let name_plural: String
    let type: String
}

struct CurrencyRate: Decodable {
    let data: [String: Double]
}

class CurrencyAPI {
    static let shared = CurrencyAPI()
    private let baseURL = "https://api.freecurrencyapi.com/v1/"
    private let session = URLSession.shared
    
    func getAPIKey() -> String? {
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path) as? [String: Any] {
            let apiKey = config["API_KEY"] as? String
            return apiKey
        }
        return nil
    }
    
    func getCurrenciesList(completion: @escaping (Result<[String], Error>) -> Void) {
        var request = URLRequest(url: URL(string: "\(baseURL)currencies")!)
        request.httpMethod = "GET"
        request.addValue(getAPIKey()!, forHTTPHeaderField: "apikey")

        
        session.dataTask(with: request) { data, response, error in
            // Проверка ошибки
            if let error = error {
                completion(.failure(error))
                return
            }
            // Проверка данных
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            // Декодирование JSON
            do {
                let currencies = try JSONDecoder().decode(CurrenciesListResponse.self, from: data)
                completion(.success(Array(currencies.data.keys).sorted()))
                
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func getCurrenciesRates(baseCurrency: String, targetCurrency: String, completion: @escaping (Result<Double, Error>) -> Void) {
        var request = URLRequest(url: URL(string: "\(baseURL)latest?base_currency=\(baseCurrency)&currencies=\(targetCurrency)")!)
        request.httpMethod = "GET"
        request.addValue(getAPIKey()!, forHTTPHeaderField: "apikey")
        
        session.dataTask(with: request) { data, response, error in
            
            if let error = error {
                    print("Request Error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
            
            guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: 0)))
                    return
                }
            
            // Распечатываем ответ для отладки
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response JSON: \(jsonString)")
                }
            
            do {
                let rate = try JSONDecoder().decode(CurrencyRate.self, from: data)
                completion(.success(rate.data[targetCurrency] ?? 0.0))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
