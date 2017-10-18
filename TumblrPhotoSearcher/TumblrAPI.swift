//
//  TumblrAPI.swift
//  TumblrPhotoSearcher
//
//  Created by Evgeniy Gutorov on 10/18/17.
//  Copyright © 2017 Evgeniy Gutorov. All rights reserved.
//

//Api page - https://www.tumblr.com/docs/en/api/v2
import Foundation
import Alamofire
import AlamofireImage

enum TumblrError:Error, LocalizedError {
  case internalError(message:String)
  
  var localizedDescription: String {
    switch self {
    case let .internalError(message):
      return message
    }
  }
}

class TumblrAPI {
  let imageDownloader:ImageDownloader = ImageDownloader()
  
  private let scheme = "https"
  private let host = "api.tumblr.com"
  private let apiKey = "WcpTglRqBESJWGcLp6fzNJRZkk4xZls9u1e3YRegECDM53midC"
  
  private func createURL(path:String, parameters:[String:String]) -> URL {
    var components = URLComponents()
    components.scheme = scheme
    components.host = host
    components.path = path
    
    var queryItems:[URLQueryItem] = parameters.map { URLQueryItem(name:$0, value:$1) }
    queryItems.append(URLQueryItem(name: "api_key", value: apiKey))
    components.queryItems = queryItems
    
    return components.url!
  }
  
  func loadPosts(tag:String, completion:@escaping (Result<[TumblrPost]>)->Void) {
    guard !tag.isEmpty else { completion(Result.success([])); return }
    let parameters = ["tag":tag]
    let url = createURL(path: "/v2/tagged", parameters:parameters)
    
    Alamofire.request(url).responseData { response in
      switch response.result {
      case let .success(jsonData):
        do {
          let tumblrResponse = try JSONDecoder().decode(TumblrResponse.self, from: jsonData)
          if 200..<300 ~= tumblrResponse.meta.status {
            completion(Result.success(tumblrResponse.response ?? []))
          }
          else {
            completion(Result.failure(TumblrError.internalError(message: tumblrResponse.meta.msg)))
          }
        } catch {
          completion(Result.failure(error))
        }
      case let .failure(error):
        completion(Result.failure(error))
      }
    }
  }
}
