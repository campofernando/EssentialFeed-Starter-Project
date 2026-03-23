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
    
    func loadImageData(from url: URL) {
        client.get(from: url) { _ in }
    }
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSut()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromUrl() {
        let (sut, client) = makeSut()
        
        sut.loadImageData(from: anyURL())
        
        XCTAssertEqual(client.requestedURLs, [anyURL()])
    }
    
    func test_loadTwice_requestsDataFromURL() {
        let (sut, client) = makeSut()
        
        sut.loadImageData(from: anyURL())
        sut.loadImageData(from: anyURL())
        
        XCTAssertEqual(client.requestedURLs, [anyURL(), anyURL()])
    }
    
    private func makeSut() -> (RemoteFeedImageDataLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private(set) var requestedURLs = [URL]()
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            requestedURLs.append(url)
        }
    }
}
