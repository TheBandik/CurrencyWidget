//
//  ContentView.swift
//  CurrencyWidget
//
//  Created by Arkadiy Schneider on 12.01.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var currencyPairs: [String: Double] = [:]
    @State private var firstCurrency: String = "USD"
    @State private var secondCurrency: String = "RUB"
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Валюта №1", text: $firstCurrency)
                    TextField("Валюта №2", text: $secondCurrency)
                }
                .textFieldStyle(.roundedBorder)
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
        let currencyPair = "\(firstCurrency)/\(secondCurrency)"
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
