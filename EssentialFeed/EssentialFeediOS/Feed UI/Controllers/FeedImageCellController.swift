//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Fernando Campo Garcia on 26/04/25.
//

import UIKit

final class FeedImageCellController {
    private let presenter: FeedImagePresenter<FeedImageCellController, UIImage>
    private lazy var cell = FeedImageCell()
    
    init(presenter: FeedImagePresenter<FeedImageCellController, UIImage>) {
        self.presenter = presenter
    }
    
    func view() -> UITableViewCell {
        presenter.loadImageData()
        return cell
    }
    
    func preload() {
        presenter.loadImageData()
    }
    
    func cancelLoad() {
        presenter.cancelImageDataLoad()
    }
}

extension FeedImageCellController: FeedImageView {
    func display(_ model: FeedImageViewModel<UIImage>) {
        cell.locationContainer.isHidden = !model.hasLocation
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.onRetry = presenter.loadImageData
        
        cell.feedImageView.image = model.image
        cell.feedImageContainer.isShimmering = model.isLoading
        cell.feedImageRetryButton.isHidden = !model.shouldRetry
    }
}
