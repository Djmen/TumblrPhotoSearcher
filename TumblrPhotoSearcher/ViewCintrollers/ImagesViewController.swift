//
//  ViewController.swift
//  TumblrPhotoSearcher
//
//  Created by Evgeniy Gutorov on 10/18/17.
//  Copyright © 2017 Evgeniy Gutorov. All rights reserved.
//

import UIKit
import SwiftMessages

class ImagesViewController: UIViewController {
  @IBOutlet weak private var tableView:UITableView!
  @IBOutlet weak private var searchBar:UISearchBar!
  @IBOutlet weak private var noDataLabel:UILabel!
  @IBOutlet weak private var activityIndicator:UIActivityIndicatorView!
  
  lazy private var infoView:MessageView = {let info = MessageView.viewFromNib(layout: .messageView)
    info.configureTheme(.info)
    info.button?.isHidden = true
    SwiftMessages.defaultConfig.presentationStyle = .bottom
    SwiftMessages.defaultConfig.duration = .seconds(seconds: 5.25)
    return info
  }()
  
  private var posts:[TumblrPost] = []
  private let tumblrAPI = TumblrAPI()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = UITableViewAutomaticDimension
    searchBar.autocapitalizationType = .none
  }
  
  private func searchImages(with tag:String) {
    clearTable()
    
    startLoadingActivity()
    tumblrAPI.loadPosts(tag: tag) {[weak self]  result in
      if let strongSelf = self {
        strongSelf.stopLoadingActivity()
        switch result {
        case .success(let newPosts):
          strongSelf.posts = newPosts.filter { $0.type == .photo }
          strongSelf.reloadUI()
        case .failure(let error):
          strongSelf.infoView.configureContent(title: "Unable to load posts", body: error.localizedDescription)
          // Show the message.
          SwiftMessages.show(config: SwiftMessages.defaultConfig, view: strongSelf.infoView)
        }
      }
    }
  }
  
  private func clearTable() {
    posts = []
    tableView.reloadData()
    noDataLabel.text = ""
  }
  
  private func reloadUI() {
    tableView.reloadData()
    if let tag = searchBar.text, !tag.isEmpty, posts.isEmpty {
      noDataLabel.text = "No photo posts with tag \"\(tag)\""
    }
    else {
      noDataLabel.text = ""
    }
  }
  
  private func startLoadingActivity() {
    searchBar.isUserInteractionEnabled = false
    activityIndicator.startAnimating()
  }
  
  private func stopLoadingActivity() {
    searchBar.isUserInteractionEnabled = true
    activityIndicator.stopAnimating()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    if let imageDetailVC = segue.destination as? ImageDetailViewController,
      let cell = sender as? ImageCell,
      let row = tableView.indexPath(for: cell)?.row
    {
      let post = posts[row]
      imageDetailVC.title = post.summary
      imageDetailVC.post = post
      imageDetailVC.imgDownloader = tumblrAPI.imageDownloader
    }
  }
}

extension ImagesViewController:UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return posts.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ImageCell.reuseID, for:indexPath) as! ImageCell
    cell.configureCell(post: posts[indexPath.row], imageDownloader:tumblrAPI.imageDownloader)
    
    return cell
  }
}

extension ImagesViewController:UISearchBarDelegate {
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBar.setShowsCancelButton(true, animated: true)
    noDataLabel.text = ""
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.setShowsCancelButton(false, animated: true)
    searchBar.resignFirstResponder()
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBarCancelButtonClicked(searchBar)
    searchImages(with: searchBar.text ?? "")
  }
}
