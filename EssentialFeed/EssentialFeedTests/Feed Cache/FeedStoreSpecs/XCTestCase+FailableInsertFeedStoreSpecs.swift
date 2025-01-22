//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Fernando Campo Garcia on 22/01/25.
//

import XCTest
import EssentialFeed

extension FailableInsertSpecs where Self: XCTestCase {
    func assertThatInsertDeliversFailureOnRetrievalError(
        on sut: FeedStore, file: StaticString = #file, line: UInt = #line
    ) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }

    func assertThatInsertHasNoSideEffectsOnFailure(
        on sut: FeedStore, file: StaticString = #file, line: UInt = #line
    ) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut, toRetrieve: .empty)
    }
}
