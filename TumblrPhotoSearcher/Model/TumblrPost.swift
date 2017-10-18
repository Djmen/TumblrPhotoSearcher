//
//  TumblrPost.swift
//  TumblrPhotoSearcher
//
//  Created by Evgeniy Gutorov on 10/18/17.
//  Copyright © 2017 Evgeniy Gutorov. All rights reserved.
//

import Foundation

struct TumblrPost:Codable {
  enum BlogType:String, Codable {
    case text
    case quote
    case link
    case answer
    case video
    case audio
    case photo
    case chat
  }
  
  struct TumblrPhoto:Codable {
    var caption:String
    var originalSizePhoto:TumblrImageInfo
    
    enum CodingKeys : String, CodingKey {
      case caption
      case originalSizePhoto = "original_size"
    }
  }
  
  var id:Int
  var blogName:String
  var summary:String?
  var type:BlogType
  var photos:[TumblrPhoto]?
  
  enum CodingKeys : String, CodingKey {
    case id
    case blogName = "blog_name"
    case summary
    case type
    case photos
  }
}
