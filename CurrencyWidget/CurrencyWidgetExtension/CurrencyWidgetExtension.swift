//
//  CurrencyWidgetExtension.swift
//  CurrencyWidgetExtension
//
//  Created by Arkadiy Schneider on 12.01.2025.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), baseCurrency: "USD", rates: ["EUR": 0.85, "GBP": 0.75])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let defaults = UserDefaults(suiteName: "com.myapp.currencyRates")
        if let savedRates = defaults?.dictionary(forKey: "currencyRates") as? [String: Double] {
            let entry = SimpleEntry(date: Date(), baseCurrency: "USD", rates: savedRates)
            completion(entry)
        } else {
            // Если данных нет, возвращаем заглушку
            let entry = SimpleEntry(date: Date(), baseCurrency: "USD", rates: ["EUR": 0.85, "GBP": 0.75])
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Получаем актуальные курсы валют из UserDefaults
        let defaults = UserDefaults(suiteName: "com.myapp.currencyRates")
        if let savedRates = defaults?.dictionary(forKey: "currencyRates") as? [String: Double] {
            let entry = SimpleEntry(date: Date(), baseCurrency: "USD", rates: savedRates)
            entries.append(entry)
        } else {
            let entry = SimpleEntry(date: Date(), baseCurrency: "USD", rates: ["EUR": 0.85, "GBP": 0.75])
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}



struct CurrencyRatesWidgetEntryView: View {
    var entry: SimpleEntry

    var body: some View {
        VStack {
            Text("Base Currency: \(entry.baseCurrency)")
                .font(.headline)
            ForEach(entry.rates.keys.sorted(), id: \.self) { key in
                Text("\(key): \(entry.rates[key] ?? 0.0, specifier: "%.2f")")
            }
        }
        .padding()
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let baseCurrency: String
    let rates: [String: Double]
}

struct CurrencyWidgetExtension: Widget {
    let kind: String = "CurrencyRatesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CurrencyRatesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Currency Rates")
        .description("Displays the current currency rates")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct CurrencyRatesWidget_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyRatesWidgetEntryView(entry: SimpleEntry(date: Date(), baseCurrency: "USD", rates: ["EUR": 0.85, "GBP": 0.75]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
