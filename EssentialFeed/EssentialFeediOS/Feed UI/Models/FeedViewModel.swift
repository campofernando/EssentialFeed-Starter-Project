//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Fernando Campo Garcia on 27/04/25.
//

import EssentialFeed

final class FeedViewModel {
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onChange: ((FeedViewModel) -> Void)?
    var onFeedLoad: (([FeedImage]) -> Void)?
    
    var isLoading: Bool = false {
        didSet {
            onChange?(self)
        }
    }
    
    func loadFeed() {
        isLoading = true
        feedLoader.load { [weak self] result in
            if case .success(let feed) = result {
                self?.onFeedLoad?(feed)
            }
            self?.isLoading = false
        }
    }
}
