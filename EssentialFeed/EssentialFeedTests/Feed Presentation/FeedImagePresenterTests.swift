//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Fernando Campo Garcia on 19/10/25.
//

import XCTest
import EssentialFeed

protocol FeedImageView {
    associatedtype Image
    func display(_ model: FeedImageViewModel<Image>)
}

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        location != nil
    }
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    let view: View
    private let imageTransformer: (Data) -> Image?
    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(
            FeedImageViewModel(
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: true,
                shouldRetry: false
            )
        )
    }
    
    func didFinishLoadingImage(with data: Data, for model: FeedImage) {
        let image = imageTransformer(data)
        view.display(
            FeedImageViewModel(
                description: model.description,
                location: model.location,
                image: image,
                isLoading: false,
                shouldRetry: image == nil
            )
        )
    }
    
    func didFinishLoadingImageWithError(_ error: Error, for model: FeedImage) {
        view.display(
            FeedImageViewModel(
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: false,
                shouldRetry: true
            )
        )
    }
}

class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingImageData_displaysLoadingImage() {
        let (sut, view) = makeSUT()
        let image = uniqueImage()
        
        sut.didStartLoadingImageData(for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertNil(message?.image)
        XCTAssertTrue(message?.isLoading ?? false)
        XCTAssertFalse(message?.shouldRetry ?? true)
    }
    
    func test_didFinishLoadingImage_displaysRetryOnFailedImageDataTransformation() {
        let (sut, view) = makeSUT(imageTransformer: fail)
        let data = Data()
        let image = uniqueImage()
        
        sut.didFinishLoadingImage(with: data, for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertNil(message?.image)
        XCTAssertFalse(message?.isLoading ?? true)
        XCTAssertTrue(message?.shouldRetry ?? false)
    }
    
    func test_didFinishLoadingImage_displaysImageOnSuccessfulImageDataTransformation() {
        let data = Data()
        let image = uniqueImage()
        let transformedData = AnyImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })
        
        sut.didFinishLoadingImage(with: data, for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.image, transformedData)
        XCTAssertFalse(message?.isLoading ?? true)
        XCTAssertFalse(message?.shouldRetry ?? true)
    }
    
    func test_didFinishLoadingImageDataWithError_displaysRetry() {
        let error = anyNSError()
        let image = uniqueImage()
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingImageWithError(error, for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertNil(message?.image)
        XCTAssertFalse(message?.isLoading ?? true)
        XCTAssertTrue(message?.shouldRetry ?? false)
    }
    
    private func makeSUT(imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil },
                         file: StaticString = #file,
                         line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, AnyImage>,
                                                 view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        return (sut, view)
    }
    
    private var fail: (Data) -> AnyImage? {
        return { _ in nil }
    }
    
    struct AnyImage: Equatable { }
    
    private class ViewSpy: FeedImageView {
        private(set) var messages = [FeedImageViewModel<AnyImage>]()
        
        func display(_ model: FeedImageViewModel<AnyImage>) {
            messages.append(model)
        }
    }
}
