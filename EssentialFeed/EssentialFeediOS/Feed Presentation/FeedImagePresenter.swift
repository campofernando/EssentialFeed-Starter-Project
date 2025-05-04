//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by Fernando Campo Garcia on 04/05/25.
//

import Foundation
import EssentialFeed

protocol FeedImageView {
    associatedtype Image
    
    func display(_ model: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    typealias Observer<T> = (T) -> Void
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private let imageTransformer: (Data) -> Image?
    var view: View?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    func loadImageData() {
        view?.display(
            FeedImageViewModel(
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: true,
                shouldRetry: false
            )
        )
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            self?.handle(result: result)
        }
    }
    
    private func handle(result: FeedImageDataLoader.Result) {
        if case .success(let data) = result,
           let image = imageTransformer(data) {
            view?.display(
                FeedImageViewModel(
                    description: model.description,
                    location: model.location,
                    image: image,
                    isLoading: false,
                    shouldRetry: false
                )
            )
        } else {
            view?.display(
                FeedImageViewModel(
                    description: model.description,
                    location: model.location,
                    image: nil,
                    isLoading: false,
                    shouldRetry: true
                )
            )
        }
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
