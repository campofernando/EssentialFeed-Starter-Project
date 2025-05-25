//
//  FeedImageDataLoaderAdapter.swift
//  EssentialFeediOS
//
//  Created by Fernando Campo Garcia on 24/05/25.
//

import EssentialFeed

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>:
    FeedImageCellControllerDelegate where View.Image == Image {
    
    var presenter: FeedImagePresenter<View, Image>?
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    
    init(imageLoader: FeedImageDataLoader, model: FeedImage) {
        self.imageLoader = imageLoader
        self.model = model
    }
    
    func didRequestImage() {
        let model = self.model
        presenter?.didStartLoadingImageData(for: model)
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            switch result {
            case .success(let data):
                self?.presenter?.didFinishLoadingImage(with: data, for: model)
            case .failure(let error):
                self?.presenter?.didFinishLoadingImageWithError(error, for: model)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
        task = nil
    }
}
