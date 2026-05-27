//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Fernando Campo Garcia on 18/05/26.
//

import Foundation

public final class RemoteFeedImageDataLoader: FeedImageDataLoader {
    let client: HTTPClient
    
    public enum Error: Swift.Error, Equatable {
        case connectivity(underlying: Swift.Error)
        case invalidData
        
        public static func == (lhs: Error, rhs: Error) -> Bool {
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
    
    private final class HTTPTaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        var wrapped: HTTPClientTask?
        
        init(_ completion: ((FeedImageDataLoader.Result) -> Void)?) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }

    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            task.complete(
                with: result.mapError { error in
                    Error.connectivity(underlying: error)
                }.flatMap { (data, response) in
                    let isValidData = response.statusCode == 200 && !data.isEmpty
                    return isValidData ? .success(data) : .failure(Error.invalidData)
                }
            )
        }
        return task
    }
}
