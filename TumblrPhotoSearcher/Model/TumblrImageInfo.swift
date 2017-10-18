//
//  TumblrImageInfo.swift
//  TumblrPhotoSearcher
//
//  Created by Evgeniy Gutorov on 10/18/17.
//  Copyright © 2017 Evgeniy Gutorov. All rights reserved.
//

import UIKit

struct TumblrImageInfo:Codable {
  var url:URL
  var width:Int
  var height:Int
}

private let thumbnailWidth = UIScreen.main.bounds.width

extension TumblrImageInfo {
  var thumbnailSize:CGSize {
    let scale = thumbnailWidth / CGFloat(width)
    return CGSize(width:thumbnailWidth, height:CGFloat(height)*scale)
  }
}
