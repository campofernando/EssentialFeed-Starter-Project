//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Fernando Campo Garcia on 17/01/25.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage {
    FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let feed = [uniqueImage(), uniqueImage()]
    let localItems = feed.map { feedItem in
        LocalFeedImage(
            id: feedItem.id,
            description: feedItem.description,
            location: feedItem.location,
            url: feedItem.url
        )
    }
    return (feed, localItems)
}

extension Date {
    func minusFeedCacheMaxAge() -> Date {
        return self.adding(days: -7)
    }
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
