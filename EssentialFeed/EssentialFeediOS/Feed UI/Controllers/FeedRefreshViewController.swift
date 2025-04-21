//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Fernando Campo Garcia on 21/04/25.
//

import UIKit
import EssentialFeed

final public class FeedRefreshViewController: NSObject {
    public lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onRefresh: (([FeedImage]) -> Void)?
    
    @objc func refresh() {
        view.beginRefreshing()
        feedLoader.load { [weak self] result in
            if case .success(let feed) = result {
                self?.onRefresh?(feed)
            }
            self?.view.endRefreshing()
        }
    }
}
