//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Fernando Campo Garcia on 26/04/25.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class FeedImageCellController {
    private let delegate: FeedImageCellControllerDelegate
    private lazy var cell = FeedImageCell()
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view() -> UITableViewCell {
        delegate.didRequestImage()
        return cell
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        delegate.didCancelImageRequest()
    }
}

extension FeedImageCellController: FeedImageView {
    func display(_ model: FeedImageViewModel<UIImage>) {
        cell.locationContainer.isHidden = !model.hasLocation
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.onRetry = delegate.didRequestImage
        
        cell.feedImageView.image = model.image
        cell.feedImageContainer.isShimmering = model.isLoading
        cell.feedImageRetryButton.isHidden = !model.shouldRetry
    }
}
