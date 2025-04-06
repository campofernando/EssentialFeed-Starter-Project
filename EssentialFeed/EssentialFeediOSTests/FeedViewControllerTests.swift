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
    private var onViewIsAppearing: ((FeedViewController) -> Void)?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        onViewIsAppearing = { vc in
            vc.load()
            vc.onViewIsAppearing = nil
        }
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        onViewIsAppearing?(self)
    }
    
    @objc func load() {
        refresh()
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
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
        
        sut.simulateAppearance()
        
        XCTAssertEqual(spy.loadCallCount, 1)
    }
    
    func test_pullToRefresh_loadsFeed() {
        let (sut, spy) = makeSUT()
        
        sut.simulateAppearance()
        sut.refreshControl?.simulatePullToRefresh()
        
        XCTAssertEqual(spy.loadCallCount, 2)
        
        sut.refreshControl?.simulatePullToRefresh()
        
        XCTAssertEqual(spy.loadCallCount, 3)
    }
    
    func test_viewDidLoad_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertTrue(sut.refreshControl!.isRefreshing)
        
        sut.refreshControl?.endRefreshing()
        
        sut.simulateAppearance()
        XCTAssertFalse(sut.refreshControl!.isRefreshing)
    }
    
    func test_viewDidLoad_hidesLoaderIndicatorOnLoaderCompletion() {
        let (sut, spy) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertTrue(sut.refreshControl!.isRefreshing)
        
        spy.completeFeedLoading()
        XCTAssertFalse(sut.refreshControl!.isRefreshing)
    }
    
    func test_pullToRefresh_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.replaceRefreshControlWithFakeForiOS17Suppport()
        sut.refreshControl?.simulatePullToRefresh()
        
        XCTAssertTrue(sut.refreshControl!.isRefreshing)
    }
    
    func test_pullToRefresh_hidesLoaderIndicatorOnLoaderCompletion() {
        let (sut, spy) = makeSUT()
        
        sut.replaceRefreshControlWithFakeForiOS17Suppport()
        sut.refreshControl?.simulatePullToRefresh()
        spy.completeFeedLoading()
        
        XCTAssertFalse(sut.refreshControl!.isRefreshing)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
    
    class LoaderSpy: FeedLoader {
        private var completions = [(EssentialFeed.LoadFeedResult) -> Void]()
        
        var loadCallCount: Int {
            completions.count
        }
        
        func load(completion: @escaping (EssentialFeed.LoadFeedResult) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading() {
            completions[0](.success([]))
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
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            replaceRefreshControlWithFakeForiOS17Suppport()
        }
        
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
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
