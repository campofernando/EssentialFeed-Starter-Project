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
            switch result {
            case let .success(data, response):
                completion(RemoteFeedLoader.map(data, response: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, response: HTTPURLResponse) -> Result {
        do {
            let remoteItems = try FeedItemsMapper.map(data, response)
            return .success(remoteItems.toModels())
        } catch {
            return .failure(error)
        }
    }
}

extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedItem] {
        return map { remoteFeedItem in
            FeedItem(
                id: remoteFeedItem.id,
                description: remoteFeedItem.description,
                location: remoteFeedItem.location,
                imageURL: remoteFeedItem.image
            )
        }
    }
}
