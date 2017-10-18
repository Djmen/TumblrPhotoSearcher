//
//  UIImage+clear.swift
//  TumblrPhotoSearcher
//
//  Created by Evgeniy Gutorov on 10/19/17.
//  Copyright © 2017 Evgeniy Gutorov. All rights reserved.
//

import UIKit

extension UIImage {
  static func clearImage(withSize size:CGSize) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image!
  }
}
