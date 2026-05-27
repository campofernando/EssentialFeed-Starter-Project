//
//  URLProtocolStub.swift
//  EssentialFeedTests
//
//  Created by Fernando Campo Garcia on 27/05/26.
//

import Foundation

class URLProtocolStub: URLProtocol {
    private struct Stub {
        let onStartLoading: (URLProtocol) -> Void
    }
    
    private static var _stub: Stub?
    private static var stub: Stub? {
        get {
            queue.sync { _stub }
        }
        set {
            queue.sync { _stub = newValue }
        }
    }

    private static let queue = DispatchQueue(label: "URLProtocolStub.queue")
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub(onStartLoading: { urlProtocol in
            if let data = data {
                urlProtocol.client?.urlProtocol(urlProtocol, didLoad: data)
            }
            
            if let response = response {
                urlProtocol.client?.urlProtocol(urlProtocol, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = error {
                urlProtocol.client?.urlProtocol(urlProtocol, didFailWithError: error)
            } else {
                urlProtocol.client?.urlProtocolDidFinishLoading(urlProtocol)
            }
        })
    }
    
    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
        stub = Stub(onStartLoading: { urlProtocol in
            observer(urlProtocol.request)
        })
    }
    
    static func onStartLoading(observer: @escaping () -> Void) {
        stub = Stub(onStartLoading: { _ in
            observer()
        })
    }
    
    static func removeStub() {
        stub = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        URLProtocolStub.stub?.onStartLoading(self)
    }
    
    override func stopLoading() {}
}
