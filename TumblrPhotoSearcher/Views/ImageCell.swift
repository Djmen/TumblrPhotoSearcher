//
//  ImageCell.swift
//  TumblrPhotoSearcher
//
//  Created by Evgeniy Gutorov on 10/18/17.
//  Copyright © 2017 Evgeniy Gutorov. All rights reserved.
//

import UIKit
import AlamofireImage

private let thumbnailID = "Thumbnail"


/// ImageCell displays thumbnail image
class ImageCell: UITableViewCell {
  static let reuseID = "ImageCellID"
  var imgDownloader:ImageDownloader!
  
  @IBOutlet weak private var photoView:UIImageView!
  @IBOutlet weak private var activityIndicator:UIActivityIndicatorView!
  @IBOutlet weak private var reloadButton:UIButton!
  
  private var imageInfo:TumblrImageInfo!
  private var requestReceipt:RequestReceipt?
  
  func configureCell(post:TumblrPost, imageDownloader:ImageDownloader) {
    imgDownloader = imageDownloader
    photoView.image = nil
    if let imageInfo = post.photos?.first?.originalSizePhoto {
      self.imageInfo = imageInfo
      loadImage()
    }
  }
  
  func loadImage() {
    reloadButton.isHidden = true
    let request = URLRequest(url: imageInfo.url)
    //Set clear image for keeping place untill it will be downloaded
    photoView.image = UIImage.clearImage(withSize: imageInfo.thumbnailSize)
    
    //Try to get thumbnail image from cache
    if let image = imgDownloader.imageCache?.image(for: request, withIdentifier: thumbnailID) {
      photoView.image = image
    }
    else { //Download original photo (It can also return cached original image without network requst)
      activityIndicator.startAnimating()
      requestReceipt = imgDownloader.download(request) {[weak self, size = imageInfo.thumbnailSize] response in
        if let strongSelf = self {
          strongSelf.requestReceipt = nil
          strongSelf.activityIndicator.stopAnimating()
          
          switch response.result {
          case .success(let image):
            let thumbnailImage = image.af_imageScaled(to: size)
            //Add thumbnail image to cache
            strongSelf.imgDownloader.imageCache?.add(thumbnailImage, for: response.request!, withIdentifier: thumbnailID)
            if strongSelf.imageInfo.url == response.request?.url {
              strongSelf.photoView.image = thumbnailImage
            }
          case .failure(let error):
            guard let error = error as? AFIError, error == .requestCancelled  else {//Ignore cancel request
              //Show button for reload
              strongSelf.reloadButton.isHidden = false
              return
            }
          }
          
        }
      }
    }
  }
  
  @IBAction func reloadCell(sender:UIButton) {
    loadImage()
  }
  
  override func prepareForReuse() {
    //cancel downloading
    if let receipt = requestReceipt {
      imgDownloader.cancelRequest(with: receipt)
      requestReceipt = nil
    }
    
    photoView.image = nil
    reloadButton.isHidden = true
    activityIndicator.stopAnimating()
  }
}
