//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Fernando Campo Garcia on 20/10/25.
//

public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var hasLocation: Bool {
        location != nil
    }
}
