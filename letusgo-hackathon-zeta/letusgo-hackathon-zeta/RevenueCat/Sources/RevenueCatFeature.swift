//
//  RevenueCatFeature.swift
//  letusgo-hackathon-zeta
//
//  Created by Geon Woo lee on 7/19/25.
//

import Foundation
import RevenueCat

enum RevenueCatFeature {
    /// 앱 시작시에 한번만 호출
    static func configure() {
        Purchases.logLevel = .verbose
        Purchases.proxyURL = RevenueCatFeature.proxyURL.flatMap { URL(string: $0) }
        Purchases.configure(withAPIKey: RevenueCatFeature.apiKey)
    }
    
    private static let apiKey: String = {
        Bundle.main.object(forInfoDictionaryKey: "REVENUECAT_API_KEY") as? String ?? ""
    }()

    private static let proxyURL: String? = {
        guard
            var scheme = Bundle.main.object(forInfoDictionaryKey: "REVENUECAT_PROXY_URL_SCHEME") as? String,
            !scheme.isEmpty,
            let host = Bundle.main.object(forInfoDictionaryKey: "REVENUECAT_PROXY_URL_HOST") as? String,
            !host.isEmpty else {
            return nil
        }
        if !scheme.hasSuffix(":") {
            scheme.append(":")
        }
        return "\(scheme)//\(host)"
    }()
}
