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
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                guard response.statusCode == 200 else {
                    completion(.failure(Error.invalidData))
                    return
                }
                completion(.success(data))
            case let .failure(error):
                completion(.failure(error))
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
        
        sut.loadImageData(from: anyURL()) { result in
            switch result {
            case let .success(receivedData):
                XCTFail("Expected failure, got success with data: \(receivedData)")
            case let .failure(receivedError):
                XCTAssertEqual(receivedError as NSError, error)
            }
            
            expectation.fulfill()
        }
        
        client.complete(with: error)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSut()
        let statusCode = 500
        
        let expectation = expectation(description: "Wait for load completion")
        
        sut.loadImageData(from: anyURL()) { result in
            switch result {
            case .success(_):
                XCTFail("Expected failure, got success")
            case .failure(let error):
                XCTAssertEqual(error as? RemoteFeedImageDataLoader.Error, RemoteFeedImageDataLoader.Error.invalidData)
            }
            expectation.fulfill()
        }
        
        client.complete(withStatusCode: statusCode, andData: Data())
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
        
        func complete(withStatusCode code: Int, andData data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            requests[index].completion(.success(data, response))
        }
    }
}
