//
//  FeedViewControllerTests.swift
//  FeedViewControllerTests
//
//  Created by Fernando Campo Garcia on 28/03/25.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {
    
    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.simulateAppearance()
        
        let bundle = Bundle(for: FeedViewController.self)
        let localizedKey = "FEED_VIEW_TITLE"
        let localizedTitle = bundle.localizedString(forKey: localizedKey, value: nil, table: "Feed")
        
        XCTAssertNotEqual(localizedKey, localizedTitle, "Missing localized string for key: \(localizedKey)")
        XCTAssertEqual(sut.title, localizedTitle)
    }
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, spy) = makeSUT()
        XCTAssertEqual(spy.loadFeedCallCount, 0, "Expected no loading request when view is created")
        
        sut.simulateAppearance()
        XCTAssertEqual(spy.loadFeedCallCount, 1, "Expected a loading request once the view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(spy.loadFeedCallCount, 2, "Expected another loading request once user initiates a load")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(spy.loadFeedCallCount, 3, "Expected a third loading request once user initiates another load")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, spy) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected a loading indicator once the view is loaded")
        
        spy.completeFeedLoading(at: 0)
        XCTAssertFalse(
            sut.isShowingLoadingIndicator,
            "Expected no loading indicator once loading is completed successfully"
        )
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected a loading indicator once the user initiates a reload")
        
        spy.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(
            sut.isShowingLoadingIndicator,
            "Expected no loading indicator once user initiated loading is completed with error"
        )
        
        sut.simulateAppearance()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator when the view appears a second time")
    }
    
    func test_loadFeedCompletion_RendersSuccessfullyLoadedFeedItems() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, spy) = makeSUT()
        
        sut.simulateAppearance()
        assertThat(sut, isRendering: [])
        
        spy.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        spy.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
        
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage(description: "a description", location: "a location")
        let (sut, spy) = makeSUT()
        
        sut.simulateAppearance()
        spy.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        spy.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, spy) = makeSUT()
        
        sut.simulateAppearance()
        spy.completeFeedLoading(with: [image0, image1])
        
        XCTAssertEqual(spy.loadedImageURLs, [], "Expected no image URL requests until views become visible")
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(
            spy.loadedImageURLs, [image0.url],
            "Expected first image URL request once first view becomes visible"
        )
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(
            spy.loadedImageURLs, [image0.url, image1.url],
            "Expected second image URL request once second view also becomes visible"
        )
    }
    
    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, spy) = makeSUT()
        
        sut.simulateAppearance()
        spy.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(
            spy.cancelledImageURLs, [],
            "Expected no cancelled image URL requests until image is not visible"
        )
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(
            spy.cancelledImageURLs, [image0.url],
            "Expected one cancelled image URL request once first image is not visible anymore"
        )
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(
            spy.cancelledImageURLs, [image0.url, image1.url],
            "Expected two cancelled image URL requests once second image is also not visible anymore"
        )
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let image0 = makeImage()
        let image1 = makeImage()
        let (sut, spy) = makeSUT()
        
        sut.simulateAppearance()
        spy.completeFeedLoading(with: [image0, image1])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        
        XCTAssertTrue(
            view0?.isShowingImageLoadingIndicator ?? false,
            "Expected loading indicator for the first view while loading first image"
        )
        XCTAssertTrue(
            view1?.isShowingImageLoadingIndicator ?? false,
            "Expected loading indicator for the second view while loading second image"
        )
        
        spy.completeImageLoading(at: 0)
        XCTAssertFalse(
            view0?.isShowingImageLoadingIndicator ?? true,
            "Expected no loading indicator for the first view once first image loading completes successfully"
        )
        XCTAssertTrue(
            view1?.isShowingImageLoadingIndicator ?? false,
            "Expected no loading indicator change for the second view once first image loading completes successfully"
        )
        
        spy.completeImageLoadingWithError(at: 1)
        XCTAssertFalse(
            view0?.isShowingImageLoadingIndicator ?? true,
            "Expected no loading indicator for the first view once first image loading completes successfully"
        )
        XCTAssertFalse(
            view1?.isShowingImageLoadingIndicator ?? true,
            "Expected no loading indicator for the second view once second image loading completes successfully"
        )
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let image0 = makeImage()
        let image1 = makeImage()
        let (sut, spy) = makeSUT()
        
        sut.simulateAppearance()
        spy.completeFeedLoading(with: [image0, image1])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while view loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while view loading second image")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        spy.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(
            view0?.renderedImage, imageData0,
            "Expected image for first view once first image loading completes successfully"
        )
        XCTAssertEqual(
            view1?.renderedImage, .none,
            "Expected no image state change for second view once first image loading completes successfully"
        )
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        spy.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(
            view0?.renderedImage, imageData0,
            "Expected image for first view once first image loading completes successfully"
        )
        XCTAssertEqual(
            view1?.renderedImage, imageData1,
            "Expected image for second view once second image loading completes successfully"
        )
    }
    
    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let image0 = makeImage()
        let image1 = makeImage()
        let (sut, spy) = makeSUT()
        
        sut.simulateAppearance()
        spy.completeFeedLoading(with: [image0, image1])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertFalse(
            view0?.isShowingRetryAction ?? true,
            "Expected no retry action for first view while loading first image"
        )
        XCTAssertFalse(
            view1?.isShowingRetryAction ?? true,
            "Expected no retry action for second view while loading second image"
        )
        
        let imageData = UIImage.make(withColor: .red).pngData()!
        spy.completeImageLoading(with: imageData, at: 0)
        XCTAssertFalse(
            view0?.isShowingRetryAction ?? true,
            "Expected no retry action for first view once first image loading completes successfully"
        )
        XCTAssertFalse(
            view1?.isShowingRetryAction ?? true,
            "Expected no retry action for second view once first image loading completes successfully"
        )
        
        spy.completeImageLoadingWithError(at: 1)
        XCTAssertFalse(
            view0?.isShowingRetryAction ?? true,
            "Expected no retry action for first view once second image loading completes with error"
        )
        XCTAssertTrue(
            view1?.isShowingRetryAction ?? false,
            "Expected retry action for second view once second image loading completes with error"
        )
    }
    
    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        let image = makeImage()
        let (sut, spy) = makeSUT()
        
        sut.simulateAppearance()
        spy.completeFeedLoading(with: [image])
        
        let view = sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertFalse(
            view?.isShowingRetryAction ?? true,
            "Expected no retry action for first view while loading first image"
        )
        
        let invalidImageData = Data("Invalid image data".utf8)
        spy.completeImageLoading(with: invalidImageData, at: 0)
        
        XCTAssertTrue(
            view?.isShowingRetryAction ?? false,
            "Expected retry action once image loading completes with invalid image data"
        )
    }
    
    func test_feedImageViewRetryAction_retriesImageLoad() {
        let image0 = makeImage()
        let image1 = makeImage()
        let (sut, spy) = makeSUT()
        
        sut.simulateAppearance()
        spy.completeFeedLoading(with: [image0, image1])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(
            spy.loadedImageURLs, [image0.url, image1.url],
            "Expected two image URL requests for the two visible views"
        )
        
        spy.completeImageLoadingWithError(at: 0)
        spy.completeImageLoadingWithError(at: 1)
        XCTAssertTrue(
            view0?.isShowingRetryAction ?? false,
            "Expected no retry action for first view once first image loading completes successfully"
        )
        XCTAssertTrue(
            view1?.isShowingRetryAction ?? false,
            "Expected no retry action for second view once first image loading completes successfully"
        )
        
        view0?.simulateRetryAction()
        XCTAssertEqual(
            spy.loadedImageURLs, [image0.url, image1.url, image0.url],
            "Expected third image URL request after first view retry action"
        )
        
        view1?.simulateRetryAction()
        XCTAssertEqual(
            spy.loadedImageURLs, [image0.url, image1.url, image0.url, image1.url],
            "Expected fourth image URL request after second view retry action"
        )
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let image0 = makeImage()
        let image1 = makeImage()
        let (sut, spy) = makeSUT()
        
        sut.simulateAppearance()
        spy.completeFeedLoading(with: [image0, image1])
        
        XCTAssertEqual(spy.loadedImageURLs, [], "Expected no image URL requests until image is near visible")
        
        sut.simulateFeedImageViewNearVisible(at: 0)
        XCTAssertEqual(
            spy.loadedImageURLs, [image0.url],
            "Expected first image URL request once first image is near visible"
        )
        
        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(
            spy.loadedImageURLs, [image0.url, image1.url],
            "Expected second image URL request once second image is near visible"
        )
    }
    
    func test_feedImageView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
        let image0 = makeImage()
        let image1 = makeImage()
        let (sut, spy) = makeSUT()
        
        sut.simulateAppearance()
        spy.completeFeedLoading(with: [image0, image1])
        
        XCTAssertEqual(
            spy.cancelledImageURLs, [],
            "Expected no cancelled image URL requests until image is near visible"
        )
        
        sut.simulateFeedImageViewNotNearVisible(at: 0)
        XCTAssertEqual(
            spy.cancelledImageURLs, [image0.url],
            "Expected first image URL request cancelled once first image is not near visible anymore"
        )
        
        sut.simulateFeedImageViewNotNearVisible(at: 1)
        XCTAssertEqual(
            spy.cancelledImageURLs, [image0.url, image1.url],
            "Expected second image URL request cancelled once second image is not near visible anymore"
        )
    }
    
    func test_feedImageView_doesNotRenderLoadedImageWhenNotVisibleAnymore() {
        let image = makeImage()
        
        let (sut, spy) = makeSUT()
        sut.simulateAppearance()
        spy.completeFeedLoading(with: [image])
        
        let view = sut.simulateFeedImageViewNotVisible(at: 0)
        spy.completeImageLoading(with: anyImageData(), at: 0)
        
        XCTAssertNil(view?.renderedImage, "Expected no redered image when an image load finishes after the view is not visible anymore")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(feedLoader: loader, imageLoader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil,
                           url: URL = URL(string: "https://any-url.com")!) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private func anyImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
    
    private func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage],
                            file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedFeedImageViews == feed.count else {
            return XCTFail(
                "Expected \(feed.count) rendered images, got \(sut.numberOfRenderedFeedImageViews) instead",
                file: file,
                line: line
            )
        }
        
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int,
                            file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail(
                "Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead",
                file: file,
                line: line
            )
        }
        
        let locationShouldBeVisible = image.location != nil
        XCTAssertEqual(
            cell.isShowingLocation, locationShouldBeVisible,
            "Expected `isShowingLocation` to be \(locationShouldBeVisible) for image view at index \(index)",
            file: file,
            line: line
        )
        
        XCTAssertEqual(
            cell.locationText, image.location,
            "Expected location text to be \(String(describing: image.location)) for image view at index \(index)",
            file: file,
            line: line
        )
        
        XCTAssertEqual(
            cell.descriptionText, image.description,
            "Expected description text to be \(String(describing: image.description)) for image view at index \(index)",
            file: file,
            line: line
        )
    }
    
    class LoaderSpy: FeedLoader, FeedImageDataLoader {
        
        // MARK: - FeedLoader
        
        private var feedRequests = [(EssentialFeed.LoadFeedResult) -> Void]()
        
        var loadFeedCallCount: Int {
            feedRequests.count
        }
        
        func load(completion: @escaping (EssentialFeed.LoadFeedResult) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an Error", code: 0)
            feedRequests[index](.failure(error))
        }
        
        // MARK: - FeedImageDataLoader
        
        private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        
        private(set) var cancelledImageURLs = [URL]()
        
        var loadedImageURLs: [URL] {
            imageRequests.map { $0.url }
        }
        
        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelCallback: () -> Void
            
            func cancel() {
                cancelCallback()
            }
        }
        
        func loadImageData(from url: URL,
                           completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            imageRequests[index].completion(.failure(error))
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

private extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(
                forTarget: target,
                forControlEvent: .touchUpInside)?
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
        refreshController?.view = fake
    }
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulateEndFeedReload() {
        refreshControl?.endRefreshing()
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int = 0) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int = 0) -> FeedImageCell? {
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        
        return view
    }
    
    func simulateFeedImageViewNearVisible(at row: Int = 0) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int = 0) {
        simulateFeedImageViewVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing ?? false
    }
    
    var numberOfRenderedFeedImageViews: Int {
        tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    private var feedImagesSection: Int {
        0
    }
    
    func feedImageView(at row: Int = 0) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}

extension FeedImageCell {
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
    
    var locationText: String? {
        locationLabel.text
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
    
    var isShowingImageLoadingIndicator: Bool {
        feedImageContainer.isShimmering
    }
    
    var renderedImage: Data? {
        feedImageView.image?.pngData()
    }
    
    var isShowingRetryAction: Bool {
        !feedImageRetryButton.isHidden
    }
    
    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
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

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }
}
