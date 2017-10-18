//
//  ImageDetailViewController.swift
//  TumblrPhotoSearcher
//
//  Created by Evgeniy Gutorov on 10/18/17.
//  Copyright © 2017 Evgeniy Gutorov. All rights reserved.
//

import UIKit
import AlamofireImage

/// ImageDetailViewController displays original image
class ImageDetailViewController: UIViewController {
  var post:TumblrPost!
  var imgDownloader:ImageDownloader!
  
  @IBOutlet weak private var scrollView:UIScrollView!
  @IBOutlet weak private var imageView: UIImageView!
  @IBOutlet weak private var activityIndicator:UIActivityIndicatorView!
  @IBOutlet weak private var infoLabel:UILabel!
  @IBOutlet weak private var reloadButton:UIButton!
  
  @IBOutlet weak private var imageViewBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak private var imageViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak private var imageViewTopConstraint: NSLayoutConstraint!
  @IBOutlet weak private var imageViewTrailingConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadImage()
  }
  
  private func loadImage() {
    guard let imageInfo = post.photos?.first?.originalSizePhoto else {
      infoLabel.text = "Unable to load  image."
      return
    }
    
    activityIndicator.startAnimating()
    //Take image from cache or download
    imgDownloader.download(URLRequest(url: imageInfo.url)) {[weak self] response in
      if let strongSelf = self {
        strongSelf.activityIndicator.stopAnimating()
        switch response.result {
        case .success(let image):
          strongSelf.imageView.image = image
          strongSelf.imageView.sizeToFit()
          strongSelf.updateMinZoomScaleForSize(strongSelf.scrollView.bounds.size)
          strongSelf.updateConstraintsForSize(strongSelf.scrollView.bounds.size, imageSize: strongSelf.imageView.frame.size)
        case .failure(let error):
          strongSelf.infoLabel.text = error.localizedDescription
          strongSelf.reloadButton.isHidden = false
        }
      }
    }
  }
  
  @IBAction private func reloadImage(sender:UIButton) {
    infoLabel.text = nil
    reloadButton.isHidden = true
    loadImage()
  }
  
  private func updateMinZoomScaleForSize(_ size: CGSize) {
    let imageSize = imageView.bounds.size
    let widthScale = size.width / imageSize.width
    let heightScale = size.height / imageSize.height
    let minScale = min(1, min(widthScale, heightScale))
    
    scrollView.minimumZoomScale = minScale
    scrollView.maximumZoomScale = 1.5
    scrollView.zoomScale = minScale
  }
  
  private func updateConstraintsForSize(_ size: CGSize, imageSize:CGSize) {
    let yOffset = max(0, (size.height - imageSize.height) / 2)
    imageViewTopConstraint.constant = yOffset
    imageViewBottomConstraint.constant = yOffset
    
    let xOffset = max(0, (size.width - imageSize.width) / 2)
    imageViewLeadingConstraint.constant = xOffset
    imageViewTrailingConstraint.constant = xOffset
    
    scrollView.layoutIfNeeded()
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    updateMinZoomScaleForSize(scrollView.bounds.size)
  }
}

extension ImageDetailViewController:UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }
  
  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    updateConstraintsForSize(scrollView.bounds.size, imageSize: imageView.frame.size)
  }
}
