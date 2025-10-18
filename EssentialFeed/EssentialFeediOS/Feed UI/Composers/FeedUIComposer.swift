//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Fernando Campo Garcia on 26/04/25.
//

import Foundation
import EssentialFeed
import UIKit

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(
            feedLoader: MainQueueDispatchDecorator(decoratee: feedLoader)
        )
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        let feedController = makeWith(
            refreshController: refreshController,
            title: FeedPresenter.title
        )
        let feedPresenter = FeedPresenter(
            feedView: FeedViewAdapter(
                controller: feedController,
                loader: MainQueueDispatchDecorator(decoratee: imageLoader)
            ),
            loadingView: WeakRefVirtualProxy(refreshController),
            errorView: WeakRefVirtualProxy(feedController)
        )
        presentationAdapter.presenter = feedPresenter
        return feedController
    }
    
    static func makeWith(refreshController: FeedRefreshViewController, title: String) -> FeedViewController {
        let feedController = FeedViewController(refreshController: refreshController)
        feedController.title = title
        return feedController
    }
}
