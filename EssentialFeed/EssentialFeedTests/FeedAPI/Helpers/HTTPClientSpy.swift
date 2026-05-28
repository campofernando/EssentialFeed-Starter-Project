//
//  HTTPClientSpy.swift
//  EssentialFeed
//
//  Created by Fernando Campo Garcia on 18/05/26.
//
import Foundation
import EssentialFeed

class HTTPClientSpy: HTTPClient {
    private struct Task: HTTPClientTask {
        let callback: () -> Void
        func cancel() { callback() }
    }
    
    var requestedURLs: [URL] {
        return requests.map { $0.url }
    }
    
    private(set) var requests = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
    private(set) var cancelledURLs = [URL]()
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        requests.append((url, completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
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
        requests[index].completion(.success((data, response)))
    }
}
