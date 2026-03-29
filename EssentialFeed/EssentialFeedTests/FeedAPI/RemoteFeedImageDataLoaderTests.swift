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
    
    enum Error: Swift.Error, Equatable {
        case connectivity(underlying: Swift.Error)
        case invalidData
        
        static func == (lhs: Error, rhs: Error) -> Bool {
            switch (lhs, rhs) {
            case (.connectivity(let lhsError), .connectivity(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            case (.invalidData, .invalidData):
                return true
            default:
                return false
            }
        }
    }
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success:
                completion(.failure(Error.invalidData))
            case let .failure(error):
                completion(.failure(Error.connectivity(underlying: error)))
            }
        }
    }
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSut()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageData_requestsDataFromUrl() {
        let (sut, client) = makeSut()
        
        sut.loadImageData(from: anyURL(), completion: { _ in })
        
        XCTAssertEqual(client.requestedURLs, [anyURL()])
    }
    
    func test_loadImageDataTwice_requestsDataFromURL() {
        let (sut, client) = makeSut()
        
        sut.loadImageData(from: anyURL(), completion: { _ in })
        sut.loadImageData(from: anyURL(), completion: { _ in })
        
        XCTAssertEqual(client.requestedURLs, [anyURL(), anyURL()])
    }
    
    func test_loadImageData_deliversErrorOnClientError() {
        let (sut, client) = makeSut()
        let error = anyNSError()
        
        expect(sut, toCompleteWithError: .connectivity(underlying: error)) {
            client.complete(with: error)
        }
    }
    
    func test_loadImageData_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSut()
        let statusCodes = [199, 201, 300, 400, 500]
        
        statusCodes.enumerated().forEach { index, statusCode in
            expect(sut, toCompleteWithError: .invalidData) {
                client.complete(withStatusCode: statusCode, andData: Data(), at: index)
            }
        }
    }
    
    func test_loadImageData_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSut()
        let data = Data()
        
        expect(sut, toCompleteWithError: .invalidData) {
            client.complete(withStatusCode: 200, andData: data)
        }
    }
    
    private func makeSut() -> (RemoteFeedImageDataLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader,
                        toCompleteWithError expectedError: RemoteFeedImageDataLoader.Error,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        
        let expectation = expectation(description: "Wait for load completion")
        
        sut.loadImageData(from: anyURL()) { result in
            switch result {
            case .success(_):
                XCTFail("Expected failure, got success", file: file, line: line)
            case .failure(let receivedError):
                XCTAssertEqual(receivedError as? RemoteFeedImageDataLoader.Error, expectedError, file: file, line: line)
            }
            expectation.fulfill()
        }
        
        action()
        wait(for: [expectation], timeout: 1.0)
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
