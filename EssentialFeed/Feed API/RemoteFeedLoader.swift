//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Fernando Campo Garcia on 11/12/24.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result  in
            guard self != nil else { return }
            
            completion(
                result
                    .mapError { _ in Error.connectivity }
                    .flatMap { (data, response) in
                        RemoteFeedLoader.map(data, response: response)
                    }
            )
        }
    }
    
    private static func map(_ data: Data, response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data, response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
}

extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        return map { feedItem in
            FeedImage(
                id: feedItem.id,
                description: feedItem.description,
                location: feedItem.location,
                url: feedItem.image
            )
        }
    }
}
