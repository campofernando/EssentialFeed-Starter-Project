//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Fernando Campo Garcia on 28/05/26.
//

import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    func retrieve(dataForURL url: URL, completion: @escaping (Error) -> Void)
}

final class LocalFeedImageDataLoader: FeedImageDataLoader {
    
    private struct Task: FeedImageDataLoaderTask {
        func cancel() { }
    }
    
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL,
                       completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        store.retrieve(dataForURL: url) { error in
            completion(.failure(error))
        }
        return Task()
    }
}

final class LocalFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() throws {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoredDataForURL() throws {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() throws {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let expectedError = anyNSError()
        
        let exp = expectation(description: "Wait for completion")
        
        _ = sut.loadImageData(from: url) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, got success instead")
            case .failure(let receivedError):
                XCTAssertEqual(receivedError as NSError, expectedError)
            }
            exp.fulfill()
        }
        store.completeWith(error: expectedError)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file,
                         line: UInt = #line) -> (LocalFeedImageDataLoader, FeedImageDataStoreSpy) {
        let spy = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: spy)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private class FeedImageDataStoreSpy: FeedImageDataStore {
        
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        
        private(set) var receivedMessages = [Message]()
        private(set) var completions = [(Error) -> Void]()
        
        func retrieve(dataForURL url: URL, completion: @escaping (Error) -> Void) {
            receivedMessages.append(.retrieve(dataFor: url))
            completions.append(completion)
        }
        
        func completeWith(error: Error, at index: Int = 0) {
            completions[index](error)
        }
    }
}
