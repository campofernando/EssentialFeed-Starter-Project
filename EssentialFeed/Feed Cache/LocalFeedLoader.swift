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
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
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
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .found(feed: feed, timestamp: timestamp):
                completion(.success(feed.toModels()))
            case .empty:
                completion(.success([]))
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
