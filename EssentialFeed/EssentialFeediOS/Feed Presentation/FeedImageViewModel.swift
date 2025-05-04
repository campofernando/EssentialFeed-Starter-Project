//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Fernando Campo Garcia on 27/04/25.
//

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        location != nil
    }
}
