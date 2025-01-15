//
//  CurrenciesViewModel.swift
//  CurrencyWidget
//
//  Created by Arkadiy Schneider on 14.01.2025.
//

import Foundation

class CurrenciesViewModel: ObservableObject {
    @Published var currencies: [String] = []
    @Published var error: String? = nil
    
    
    init() {
        CurrencyAPI.shared.getCurrenciesList { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let currenciesList):
                    self.currencies = currenciesList
                case .failure(let error):
                    self.error = error.localizedDescription
                }
            }
        }
    }
    
    func getCurrenciesRates(baseCurrency: String, targetCurrency: String, completion: @escaping (Result<Double, Error>) -> Void) {
        CurrencyAPI.shared.getCurrenciesRates(baseCurrency: baseCurrency, targetCurrency: targetCurrency) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
