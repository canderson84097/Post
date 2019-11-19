//
//  PostController.swift
//  Post
//
//  Created by Chris Anderson on 11/18/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import Foundation

class PostController {
    
    var posts: [Post] = []
    
    func fetchPosts(reset: Bool = true, completion: @escaping (Result<[Post], PostError>) -> Void) {
        
        
        let queryEndInterval = reset ? Date().timeIntervalSince1970: posts.last?.queryTimestamp ?? Date().timeIntervalSince1970
        
        let urlParameters = ["orderBy": "\"timestamp\"", "endAt": "\(queryEndInterval)", "limitToLast": "15",]
        
        let queryItems = urlParameters.compactMap({URLQueryItem(name: $0.key, value: $0.value)})
        
        
        guard let baseURL = URL(string: "https://devmtn-posts.firebaseio.com/posts.json") else { return completion(.failure(.invalidURL))}
        
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        guard let finalURL = urlComponents?.url else { return }
        
        URLSession.shared.dataTask(with: finalURL) { (data, _, error) in
            if let error = error {
                print(error, error.localizedDescription)
                completion(.failure(.communicationError))
            }
            guard let data = data else { return completion(.failure(.noData)) }
            do {
                let decoder = JSONDecoder()
                let topLevelObject = try decoder.decode([String: Post].self, from: data)
                
                var posts: [Post] = []
                posts = topLevelObject.compactMap({ $0.value })
                posts.sort(by: { $0.timestamp > $1.timestamp })
                
                if reset {
                    self.posts = posts
                } else {
                    self.posts.append(contentsOf: posts)
                }
                return completion(.success(posts))
                } catch {
                    print(error, error.localizedDescription)
                }
        }.resume()
    }
    
    // MARK: - Custom Methods
    
    func addNewPostWith(username: String, text: String, completion: @escaping (Bool) -> Void) {
        // BEFORE THE INTERNET
        guard let finalURL = URL(string: "https://devmtn-posts.firebaseio.com/posts.json") else { return completion(false) }
        var request = URLRequest(url: finalURL)
        request.httpMethod = "POST"
        do {
            let encoder = JSONEncoder()
            let post = Post(text: text, username: username)
            let postData = try encoder.encode(post.self)
            request.httpBody = postData
        } catch {
            print("There was an error encoding the post: \(error.localizedDescription)")
            return completion(false)
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            // AFTER GOING TO THE INTERNET
            if let error = error {
                print(error, error.localizedDescription)
                return completion(false)
            }
            guard let data = data else { return completion(false) }
            do {
                _ = try JSONDecoder().decode(Post.self, from: data)
                completion(true)
            } catch {
                print(error, error.localizedDescription)
                completion(false)
            }
            self.fetchPosts { (result) in
                switch result {
                case .success(_):
                    completion(true)
                case .failure(_):
                    completion(false)
                }
                
                
            }
        }.resume()
        
        
        
    }
} // END OF CLASS!

enum PostError: LocalizedError {
    case invalidURL
    case communicationError
    case noData
    case noPosts
    case unableToDecode
}
