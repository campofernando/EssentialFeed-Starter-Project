//
//  FeedViewControllerTests.swift
//  FeedViewControllerTests
//
//  Created by Fernando Campo Garcia on 28/03/25.
//

import XCTest
import UIKit
import EssentialFeed

class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        load()
    }
    
    @objc func load() {
        loader?.load { _ in }
        refresh()
    }
    
    private func refresh() {
        refreshControl?.beginRefreshing()
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let (sut, spy) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        
        XCTAssertEqual(spy.loadCallCount, 1)
    }
    
    func test_pullToRefresh_loadsFeed() {
        let (sut, spy) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        sut.refreshControl?.simulatePullToRefresh()
        
        XCTAssertEqual(spy.loadCallCount, 2)
        
        sut.refreshControl?.simulatePullToRefresh()
        
        XCTAssertEqual(spy.loadCallCount, 3)
    }
    
    func test_viewDidLoad_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFakeForiOS17Suppport()
        XCTAssertFalse(sut.refreshControl!.isRefreshing)
        
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        XCTAssertTrue(sut.refreshControl!.isRefreshing)
    }
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
    
    class LoaderSpy: FeedLoader {
        
        private(set) var loadCallCount: Int = 0
        
        func load(completion: @escaping (EssentialFeed.LoadFeedResult) -> Void) {
            loadCallCount += 1
        }
    }
}

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(
                forTarget: target,
                forControlEvent: .valueChanged)?
                .forEach {
                    (target as NSObject).perform(Selector($0))
                }
        }
    }
}

private extension FeedViewController {
    func replaceRefreshControlWithFakeForiOS17Suppport() {
        let fake = FakeRefreshControl()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(
                forTarget: target,
                forControlEvent: .valueChanged)?
                .forEach {
                    fake.addTarget(target, action: Selector($0), for: .valueChanged)
                }
        }
        
        refreshControl = fake
    }
}

private class FakeRefreshControl: UIRefreshControl {
    private var _isRefreshing = false
    
    override var isRefreshing: Bool { _isRefreshing }
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}
