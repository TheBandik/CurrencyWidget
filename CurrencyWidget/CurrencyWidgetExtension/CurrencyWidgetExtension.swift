//
//  CurrencyWidgetExtension.swift
//  CurrencyWidgetExtension
//
//  Created by Arkadiy Schneider on 12.01.2025.
//

import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date: Date
    let rates: [String: Double]
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), rates: ["USD/EUR": 1.0, "USD/RUB": 103.0])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let defaults = UserDefaults(suiteName: "group.com.arkadiy.CurrencyWidget")
        let savedRates = defaults?.dictionary(forKey: "currencyPairs") as? [String: Double] ?? [:]
        let entry = SimpleEntry(date: Date(), rates: savedRates)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        print("getTimeline called")
        
        let defaults = UserDefaults(suiteName: "group.com.arkadiy.CurrencyWidget")
        let savedRates = defaults?.dictionary(forKey: "currencyPairs") as? [String: Double] ?? [:]
        print(savedRates)
        let entry = SimpleEntry(date: Date(), rates: savedRates)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct CurrencyRatesWidgetEntryView: View {
    var entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading) {
            Text("Курс валют")
                .padding(.bottom, 10)
            ForEach(entry.rates.keys.sorted().prefix(4), id: \.self) { key in
                HStack {
                    Text(key)
                    Spacer()
                    Text("\(entry.rates[key] ?? 0.0, specifier: "%.2f")")
                }
                .font(.footnote)
                .padding(.vertical, 0.5)
            }
        }
        .containerBackground(.background, for: .widget)
    }
}

struct CurrencyWidgetExtension: Widget {
    let kind: String = "CurrencyWidgetExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CurrencyRatesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Курс валют")
        .description("Курс избранных пар валют")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct CurrencyRatesWidget_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyRatesWidgetEntryView(entry: SimpleEntry(date: Date(), rates: ["USD/EUR": 1.0, "USD/RUB": 103.0, "EUR/RUB": 78.0, "GBP/RUB": 91.0, "GBP/USD": 1.25]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
