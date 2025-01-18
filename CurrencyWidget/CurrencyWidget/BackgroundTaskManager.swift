//
//  BackgroundTaskManager.swift
//  CurrencyWidget
//
//  Created by Arkadiy Schneider on 18.01.2025.
//

import BackgroundTasks
import WidgetKit

class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    
    private let defaults = UserDefaults(suiteName: "group.com.arkadiy.CurrencyWidget")
    private let currencyPairsKey = "currencyPairs"
    
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.arkadiy.currencyUpdate", using: nil) { task in
            self.handleAppRefresh(task: task as! BGProcessingTask)
        }
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.arkadiy.currencyUpdate")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3600)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background task scheduled")
        } catch {
            print("Ошибка планирования фоновой задачи: \(error.localizedDescription)")
        }
    }
    
    private func handleAppRefresh(task: BGProcessingTask) {
        scheduleAppRefresh()
        
        guard let savedPairs = defaults?.dictionary(forKey: currencyPairsKey) as? [String: Double] else {
            task.setTaskCompleted(success: false)
            return
        }
        
        let group = DispatchGroup()
        var updatedPairs: [String: Double] = [:]
        var success = true
        
        for (pair, _) in savedPairs {
            group.enter()
            let currencies = pair.split(separator: "/")
            guard currencies.count == 2 else {
                group.leave()
                continue
            }
            
            let baseCurrency = String(currencies[0])
            let targetCurrency = String(currencies[1])
            
            CurrencyAPI.shared.getCurrenciesRates(baseCurrency: baseCurrency, targetCurrency: targetCurrency) { result in
                switch result {
                case .success(let rate):
                    updatedPairs[pair] = round(rate * 100) / 100
                case .failure:
                    success = false
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if success {
                self.saveCurrencyPairs(updatedPairs)
            }
            task.setTaskCompleted(success: success)
        }
    }
    
    private func saveCurrencyPairs(_ pairs: [String: Double]) {
        do {
            let data = try JSONEncoder().encode(pairs)
            defaults?.set(data, forKey: currencyPairsKey)
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Ошибка сохранения данных: \(error.localizedDescription)")
        }
    }
}
