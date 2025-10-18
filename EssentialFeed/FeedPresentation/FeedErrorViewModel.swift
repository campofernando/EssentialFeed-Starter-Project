//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Fernando Campo Garcia on 18/10/25.
//

import Foundation

public struct FeedErrorViewModel {
    public let message: String?
    
    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: .none)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}
