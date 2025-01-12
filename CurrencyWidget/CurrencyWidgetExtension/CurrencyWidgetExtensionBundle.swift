//
//  CurrencyWidgetExtensionBundle.swift
//  CurrencyWidgetExtension
//
//  Created by Arkadiy Schneider on 12.01.2025.
//

import WidgetKit
import SwiftUI

@main
struct CurrencyWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        CurrencyWidgetExtension()
        CurrencyWidgetExtensionControl()
        CurrencyWidgetExtensionLiveActivity()
    }
}
