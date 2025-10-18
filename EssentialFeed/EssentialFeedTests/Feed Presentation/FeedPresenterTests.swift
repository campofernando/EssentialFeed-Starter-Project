//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Fernando Campo Garcia on 18/10/25.
//

import XCTest

struct FeedLoadingViewModel {
    var isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: .none)
    }
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
    private let errorView: FeedErrorView
    private let loadingView: FeedLoadingView
    
    init (errorView: FeedErrorView, loadingView: FeedLoadingView) {
        self.errorView = errorView
        self.loadingView = loadingView
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
}

class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages when initializing")
    }
    
    func test_didStartLoadingFeed_displaysNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(
            view.messages,
            [
                .display(errorMessage: .none),
                .display(isLoading: true)
            ]
        )
    }

    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(errorView: view, loadingView: view)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        return (sut, view)
    }
    
    private class ViewSpy: FeedLoadingView, FeedErrorView {
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
        }
        
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
    }
}
