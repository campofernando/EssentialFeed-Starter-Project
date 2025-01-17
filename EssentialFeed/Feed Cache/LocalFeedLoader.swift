//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Fernando Campo Garcia on 12/01/25.
//

import Foundation

public class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    private let calendar = Calendar(identifier: .gregorian)
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    private var maxCachedAgeInDays: Int {
        return 7
    }
    
    private func cacheIsValid(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCachedAgeInDays, to: timestamp) else {
            return false
        }
        return currentDate() < maxCacheAge
    }
}

extension LocalFeedLoader {
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}
    
extension LocalFeedLoader: FeedLoader {
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .found(feed: feed, timestamp: timestamp) where self.cacheIsValid(timestamp):
                completion(.success(feed.toModels()))
                
            case .found, .empty:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
                
            case let .found(_, timestamp) where !self.cacheIsValid(timestamp):
                self.store.deleteCachedFeed { _ in }
                
            case .empty, .found: break
            }
        }
    }
}

extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { feedItem in
            LocalFeedImage(
                id: feedItem.id,
                description: feedItem.description,
                location: feedItem.location,
                url: feedItem.url
            )
        }
    }
}

extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { localFeedImage in
            FeedImage(
                id: localFeedImage.id,
                description: localFeedImage.description,
                location: localFeedImage.location,
                url: localFeedImage.url
            )
        }
    }
}
