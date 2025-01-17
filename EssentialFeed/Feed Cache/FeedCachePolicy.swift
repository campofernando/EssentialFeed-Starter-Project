//
//  FeedCachePolicy.swift
//  EssentialFeedTests
//
//  Created by Fernando Campo Garcia on 17/01/25.
//

import Foundation

final class FeedCachePolicy {
    private static let calendar = Calendar(identifier: .gregorian)
    
    private init() {}
    
    private static var maxCachedAgeInDays: Int {
        return 7
    }
    
    static func cacheIsValid(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCachedAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
