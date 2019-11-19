//
//  ViewController.swift
//  Post
//
//  Copyright © 2018 DevMtnStudent. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController {
    
    // MARK: - Properties
    
    var postController = PostController()
    
    var refreshControl = UIRefreshControl()
    
    // MARK: - Outlets
    
    
    @IBOutlet weak var postTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postTableView.refreshControl = refreshControl
        postTableView.delegate = self
        postTableView.dataSource = self
        postController.fetchPosts { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.reloadTableView()
                    
                case .failure(let error):
                    print(error)
                }
            }
            
        }
        postTableView.estimatedRowHeight = 45
        postTableView.rowHeight = UITableView.automaticDimension
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
    } // END OF VIEWDIDLOAD
    
    // MARK: - Actions
    
    @IBAction func addPostButtonPressed(_ sender: Any) {
        presentNewPostAlert()
    }
    
    // MARK: - Custom Methods
    
    func presentNewPostAlert() {
        let alertController = UIAlertController(title: "Create a post!", message: "Please enter a new post!", preferredStyle: .alert)
        let addPostButtonAction = UIAlertAction(title: "Add Post", style: .default) { (_) in
            guard let newUsername = alertController.textFields?.first?.text, !newUsername.isEmpty, let newText = alertController.textFields?.last?.text, !newText.isEmpty else { return }
            self.postController.addNewPostWith(username: newUsername, text: newText) { (success) in
                switch success {
                case true:
                    self.reloadTableView()
                case false:
                    print("Error")
                }
            }
        }
        let cancelPostButtonAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addTextField { (textField) in
            textField.placeholder = "(Enter Post Body)"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "(Enter Username)"
        }
        alertController.addAction(addPostButtonAction)
        alertController.addAction(cancelPostButtonAction)
        present(alertController, animated: true)
        
    }
    
    @objc func refreshControlPulled() {
        postController.fetchPosts { (result) in
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.reloadTableView()
            }
            
        }
    }
    func reloadTableView() {
        
        DispatchQueue.main.async {
            self.postTableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
} // END OF CLASS!

extension PostListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        let post = postController.posts[indexPath.row]
        cell.textLabel?.text = post.text
        
        cell.detailTextLabel?.text = "\(post.username) - \(post.timestamp)"
        
        return cell
    }
    
    
}

extension PostListViewController: UITableViewDelegate {
    
}

extension PostListViewController {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= postController.posts.count - 1 {
            postController.fetchPosts(reset: false) { (_) in
                self.reloadTableView()
            }
        }
    }
}
