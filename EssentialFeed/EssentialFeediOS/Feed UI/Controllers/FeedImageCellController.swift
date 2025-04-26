//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Fernando Campo Garcia on 26/04/25.
//

import Foundation
import EssentialFeed
import UIKit

final class FeedImageCellController {
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (model.location == nil)
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()
        
        let loadImage = { [weak self, weak cell] in
            guard let self else { return }
            
            task = imageLoader.loadImageData(from: model.url) { [weak cell] result in
                if case .success(let data) = result,
                   let image = UIImage(data: data) {
                    cell?.feedImageView.image = image
                } else {
                    cell?.feedImageRetryButton.isHidden = false
                }
                cell?.feedImageContainer.stopShimmering()
            }
        }
        
        cell.onRetry = loadImage
        loadImage()
        
        return cell
    }
    
    func preload() {
        task = imageLoader.loadImageData(from: model.url) { _ in }
    }
    
    func cancelLoad() {
        task?.cancel()
    }
}
