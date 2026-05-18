//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Fernando Campo Garcia on 23/03/26.
//

import XCTest
import EssentialFeed

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
    
    func test_loadImageData_deliversConnectivityErrorOnClientError() {
        let (sut, client) = makeSut()
        let error = anyNSError()
        
        expect(sut, toCompleteWith: .failure(RemoteFeedImageDataLoader.Error.connectivity(underlying: error))) {
            client.complete(with: error)
        }
    }
    
    func test_loadImageData_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSut()
        let statusCodes = [199, 201, 300, 400, 500]
        
        statusCodes.enumerated().forEach { index, statusCode in
            expect(sut, toCompleteWith: .failure(RemoteFeedImageDataLoader.Error.invalidData)) {
                client.complete(withStatusCode: statusCode, andData: Data(), at: index)
            }
        }
    }
    
    func test_loadImageData_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSut()
        let data = Data()
        
        expect(sut, toCompleteWith: .failure(RemoteFeedImageDataLoader.Error.invalidData)) {
            client.complete(withStatusCode: 200, andData: data)
        }
    }
    
    func test_loadImageDataFromURL_deliversReceivedNonEmptyDataOn200HTTPResponse() {
        let (sut, client) = makeSut()
        let data = Data("non-empty data".utf8)
        
        expect(sut, toCompleteWith: .success(data)) {
            client.complete(withStatusCode: 200, andData: data)
        }
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader! = RemoteFeedImageDataLoader(client: client)
        let data = Data("non-empty data".utf8)
        
        var capturedResults = [FeedImageDataLoader.Result]()
        sut.loadImageData(from: anyURL()) { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, andData: data)
        
        XCTAssertTrue(capturedResults.isEmpty, "Expected no results after instance has been deallocated")
    }
    
    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
        let (sut, client) = makeSut()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")
        task.cancel()
        
        XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, client) = makeSut()
        
        var received = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { result in
            received.append(result)
        }
        task.cancel()
        
        client.complete(withStatusCode: 404, andData: anyData())
        client.complete(withStatusCode: 200, andData: Data("non-empty data".utf8))
        client.complete(with: anyNSError())
        
        XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
    }
    
    // MARK: - Helpers
    
    private func makeSut(file: StaticString = #filePath,
                         line: UInt = #line) -> (RemoteFeedImageDataLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader,
                        toCompleteWith expectedResult: FeedImageDataLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        
        let expectation = expectation(description: "Wait for load completion")
        
        sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
                
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData)
                
            case let (.failure(receivedError as RemoteFeedImageDataLoader.Error),
                      .failure(expectedError as RemoteFeedImageDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            expectation.fulfill()
        }
        
        action()
        wait(for: [expectation], timeout: 1.0)
    }
}
