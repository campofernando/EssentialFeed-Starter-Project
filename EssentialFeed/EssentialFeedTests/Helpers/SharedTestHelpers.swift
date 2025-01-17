//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Fernando Campo Garcia on 17/01/25.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}
