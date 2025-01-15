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

class CurrencyAPI {
    static let shared = CurrencyAPI()
    private let baseURL = "https://api.freecurrencyapi.com/v1/"
    private let session = URLSession.shared
    
    func getCurrenciesList(completion: @escaping (Result<[String], Error>) -> Void) {
        var request = URLRequest(url: URL(string: "\(baseURL)currencies")!)
        request.httpMethod = "GET"
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path) as? [String: Any] {
            let apiKey = config["API_KEY"] as? String
            request.addValue(apiKey!, forHTTPHeaderField: "apikey")
        }
        
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
    
    //    func fetchRates(for baseCurrency: String, completion: @escaping (Result<CurrencyRate, Error>) -> Void) {
    //        let url = URL(string: "\(baseURL)\(baseCurrency)")!
    //        session.dataTask(with: url) { data, response, error in
    //            if let error = error {
    //                completion(.failure(error))
    //                return
    //            }
    //            guard let data = data else {
    //                completion(.failure(NSError(domain: "No data", code: 0)))
    //                return
    //            }
    //            do {
    //                let rates = try JSONDecoder().decode(CurrencyRate.self, from: data)
    //                completion(.success(rates))
    //            } catch {
    //                completion(.failure(error))
    //            }
    //        }.resume()
    //    }
}


