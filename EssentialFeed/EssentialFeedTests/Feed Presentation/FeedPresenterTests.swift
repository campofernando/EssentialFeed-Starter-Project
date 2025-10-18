//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Fernando Campo Garcia on 18/10/25.
//

import XCTest

final class FeedPresenter {
    
    init (view: Any) {
        
    }
}

class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()
        
        _ = FeedPresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages when initializing")
    }

    private class ViewSpy {
        let messages = [Any]()
    }
}
