//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Fernando Campo Garcia on 23/03/26.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (Error) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                completion(error)
            }
        }
    }
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSut()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromUrl() {
        let (sut, client) = makeSut()
        
        sut.loadImageData(from: anyURL(), completion: { _ in })
        
        XCTAssertEqual(client.requestedURLs, [anyURL()])
    }
    
    func test_loadTwice_requestsDataFromURL() {
        let (sut, client) = makeSut()
        
        sut.loadImageData(from: anyURL(), completion: { _ in })
        sut.loadImageData(from: anyURL(), completion: { _ in })
        
        XCTAssertEqual(client.requestedURLs, [anyURL(), anyURL()])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSut()
        let error = anyNSError()
        
        let expectation = expectation(description: "Wait for load completion")
        
        sut.loadImageData(from: anyURL()) { receivedError in
            XCTAssertEqual(receivedError as NSError, error)
            expectation.fulfill()
        }
        
        client.complete(with: error)
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func makeSut() -> (RemoteFeedImageDataLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] {
            return requests.map { $0.url }
        }
        
        private(set) var requests = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            requests.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            requests[index].completion(.failure(error))
        }
    }
}
