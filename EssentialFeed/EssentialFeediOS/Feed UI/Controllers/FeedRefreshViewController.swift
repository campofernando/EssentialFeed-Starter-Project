//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Fernando Campo Garcia on 21/04/25.
//

import UIKit
import EssentialFeed

final class FeedViewModel {
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    private enum State {
        case pending
        case loading
        case loaded([FeedImage])
        case failed
    }
    
    private var state: State = .pending {
        didSet{
            onChange?(self)
        }
    }
    
    var onChange: ((FeedViewModel) -> Void)?
    
    var isLoading: Bool {
        switch state {
        case .loading: return true
        case .pending, .loaded, .failed: return false
        }
    }
    
    var feed: [FeedImage]? {
        switch state {
        case .loaded(let feed): return feed
        case .pending, .loading, .failed: return nil
        }
    }
    
    func loadFeed() {
        state = .loading
        feedLoader.load { [weak self] result in
            if case .success(let feed) = result {
                self?.state = .loaded(feed)
            } else {
                self?.state = .failed
            }
        }
    }
}

final public class FeedRefreshViewController: NSObject {
    public lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private let viewModel: FeedViewModel
    
    init(feedLoader: FeedLoader) {
        self.viewModel = FeedViewModel(feedLoader: feedLoader)
    }
    
    var onRefresh: (([FeedImage]) -> Void)?
    
    @objc func refresh() {
        viewModel.onChange = { [weak self] viewModel in
            if viewModel.isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
            
            if let feed = viewModel.feed {
                self?.onRefresh?(feed)
            }
        }
        viewModel.loadFeed()
    }
}
