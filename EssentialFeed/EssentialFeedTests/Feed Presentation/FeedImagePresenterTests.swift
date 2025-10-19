//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Fernando Campo Garcia on 19/10/25.
//

import XCTest

class FeedImagePresenter {
    
    init(view: Any) {
        
    }
}

class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        return (sut, view)
    }
    
    private class ViewSpy {
        let messages = [Any]()
    }
}
