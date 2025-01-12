//
//  ContentView.swift
//  CurrencyWidget
//
//  Created by Arkadiy Schneider on 12.01.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var rates: [String: Double] = [:]
    @State private var baseCurrency: String = "USD"
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
                    VStack {
                        TextField("Enter base currency (e.g., USD)", text: $baseCurrency)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()

                        Button("Fetch Rates") {
                            fetchRates()
                        }

                        List(rates.sorted(by: <), id: \.key) { key, value in
                            HStack {
                                Text(key)
                                Spacer()
                                Text(String(format: "%.2f", value))
                            }
                        }
                    }
                    .navigationTitle("Currency Rates")
                }
    }
    
    private func fetchRates() {
        CurrencyAPI.shared.fetchRates(for: baseCurrency) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let currencyRate):
                    self.rates = currencyRate.rates
                    // Сохраняем курсы валют в UserDefaults
                    let defaults = UserDefaults(suiteName: "com.myapp.currencyRates")
                    defaults?.set(currencyRate.rates, forKey: "currencyRates")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
