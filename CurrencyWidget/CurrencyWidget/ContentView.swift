//
//  ContentView.swift
//  CurrencyWidget
//
//  Created by Arkadiy Schneider on 12.01.2025.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @StateObject private var currenciesViewModel = CurrenciesViewModel()
    @State private var currencyPairs: [String: Double] = [:]
    @State private var baseCurrency: String = "USD"
    @State private var targetCurrency: String = "RUB"
    @State private var errorMessage: String?
    
    let defaults = UserDefaults(suiteName: "group.currencyWidget")
    let currencyPairsKey = "currencyPairs"
    
    init() {
        loadCurrencyPairs()
    }
    
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
                    saveCurrencyPairs()
                    WidgetCenter.shared.reloadAllTimelines()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func removeCurrencyPair(pair: String) {
        currencyPairs.removeValue(forKey: pair)
        saveCurrencyPairs()
        WidgetCenter.shared.reloadTimelines(ofKind: "CurrencyWidgetExtension")
    }
    
    private func saveCurrencyPairs() {
        defaults?.set(currencyPairs, forKey: currencyPairsKey)
        WidgetCenter.shared.reloadTimelines(ofKind: "CurrencyWidgetExtension")
        print("Saved currency pairs: \(currencyPairs)")
    }
    
    private func loadCurrencyPairs() {
        if let savedPairs = defaults?.dictionary(forKey: currencyPairsKey) as? [String: Double] {
            currencyPairs = savedPairs
        }
    }
}

#Preview {
    ContentView()
}
