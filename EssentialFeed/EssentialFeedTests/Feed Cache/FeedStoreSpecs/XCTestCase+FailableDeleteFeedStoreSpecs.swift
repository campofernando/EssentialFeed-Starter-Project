//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Fernando Campo Garcia on 22/01/25.
//

import XCTest
import EssentialFeed

extension FailableDeleteSpecs where Self: XCTestCase {
    func assertThatDeleteDeliversFailureOnRetrievalError(
        on sut: FeedStore, file: StaticString = #file, line: UInt = #line
    ) {
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }

    func assertThatDeleteHasNoSideEffectsOnFailure(
        on sut: FeedStore, file: StaticString = #file, line: UInt = #line
    ) {
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .empty)
    }
}
