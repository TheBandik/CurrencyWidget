//
//  ContentView.swift
//  CurrencyWidget
//
//  Created by Arkadiy Schneider on 12.01.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var currenciesViewModel = CurrenciesViewModel()
    @State private var currencyPairs: [String: Double] = [:]
    @State private var baseCurrency: String = "USD"
    @State private var targetCurrency: String = "RUB"
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    if let error = currenciesViewModel.error {
                        Text(error)
                    }
                    Picker("Базовая валюта", selection: $baseCurrency) {
                        ForEach(currenciesViewModel.currencies, id: \.self) { currency in
                            Text(currency)
                        }
                    }
                    Picker("Целевая валюта", selection: $targetCurrency) {
                        ForEach(currenciesViewModel.currencies, id: \.self) { currency in
                            Text(currency)
                        }
                    }
                }
                .textFieldStyle(.roundedBorder)
                .pickerStyle(.navigationLink)
                .labelsHidden()
                .padding()
                
                Button("Добавить пару") {
                    addCurrencyPair()
                }
                
                List(Array(currencyPairs), id: \.key) { key, value in
                    HStack {
                        Text(key)
                        Spacer()
                        Text(String(value))
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            removeCurrencyPair(pair: key)
                        } label : {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Курс валют")
        }
    }
    
    private func addCurrencyPair() {
        let currencyPair = "\(baseCurrency)/\(targetCurrency)"
        currencyPairs[currencyPair] = 0.0
    }
    
    private func removeCurrencyPair(pair: String) {
        currencyPairs.removeValue(forKey: pair)
    }
    
    //    private func fetchRates() {
    //        CurrencyAPI.shared.fetchRates(for: baseCurrency) { result in
    //            DispatchQueue.main.async {
    //                switch result {
    //                case .success(let currencyRate):
    //                    self.rates = currencyRate.rates
    //                    let defaults = UserDefaults(suiteName: "com.myapp.currencyRates")
    //                    defaults?.set(currencyRate.rates, forKey: "currencyRates")
    //                case .failure(let error):
    //                    self.errorMessage = error.localizedDescription
    //                }
    //            }
    //        }
    //    }
}

#Preview {
    ContentView()
}
