//
//  TumblrResponse.swift
//  TumblrPhotoSearcher
//
//  Created by Evgeniy Gutorov on 10/18/17.
//  Copyright © 2017 Evgeniy Gutorov. All rights reserved.
//

import Foundation

struct TumblrResponse:Codable {
  struct Meta:Codable {
    var status:Int
    var msg:String
  }
  
  var meta:Meta
  var response:[TumblrPost]?
}
