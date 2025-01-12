//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Fernando Campo Garcia on 12/01/25.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCacheCompletion = (Error?) -> Void
    typealias InsertionCacheCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCacheCompletion)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCacheCompletion)
    func retrieve()
}
