//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Fernando Campo Garcia on 12/01/25.
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
