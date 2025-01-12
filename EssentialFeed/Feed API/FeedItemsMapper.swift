//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Fernando Campo Garcia on 25/12/24.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
    
    internal var item: FeedItem {
        .init(id: id, description: description, location: location, imageURL: image)
    }
}

internal class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    private static var OK_200: Int { return 200 }
    
    internal static func map(_ data: Data,
                             _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}
