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
        currenciesViewModel.getCurrenciesRates(baseCurrency: baseCurrency, targetCurrency: targetCurrency) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let rate):
                    self.currencyPairs[currencyPair] = Double(String(format: "%.2f", rate))
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func removeCurrencyPair(pair: String) {
        currencyPairs.removeValue(forKey: pair)
    }
}

#Preview {
    ContentView()
}
