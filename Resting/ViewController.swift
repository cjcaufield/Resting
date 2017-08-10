//
//  ViewController.swift
//  Resting
//
//  Created by Colin Caufield on 2017-07-15.
//  Copyright © 2017 Secret Geometry, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - General
    
    var posts = [Post]()
    
    override func viewDidLoad() {

        /*
        self.testGetPost()
        self.testPutPost()
        self.testPostPost()
        self.testDeletePost()
        */
    }
    
    func printPosts() {
        
        for post in self.posts {
            print(post)
            print("")
        }
    }
    
    // MARK: - Tests
    
    func testGetPost() {
        
        self.getPosts(userID: 1) { (result) in
            
            switch result {
                
            case .success(let posts):
                
                self.posts = posts
                
                print("GET posts was successful.\n")
                self.printPosts()
                
            case .failure(let error):
                
                fatalError("error: \(error.localizedDescription)")
            }
        }
    }
    
    func testPutPost() {
        
        // implement
    }
    
    func testPostPost() {
        
        let time = currentTimeString()
        
        let newPost = Post(userId: 1,
                           id: 999,
                           title: "HELLO WORLD at \(time)",
                           body: "How are you all today?")
        
        self.postPost(newPost) { (result) in
            
            switch result {
                
            case .success(let posts):
                
                assert(posts.count == 1)
                
                self.posts.append(posts.last!)
                
                print("POST post was successful.\n")
                self.printPosts()
                
            case .failure(let error):
                
                fatalError("error: \(error.localizedDescription)")
            }
        }
    }
    
    func testDeletePost() {
        
        // implement
    }
    
    // MARK: - REST
    
    func getPosts(userID: Int, completion: ((Result<[Post]>) -> Void)?) {
        
        var urlComponents = self.commonURLComponents
        urlComponents.path = "/posts"
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: "\(userID)")]
        
        let request = self.createURLRequest(urlComponents, "GET")
        
        self.dataTask(for: request, completion: completion)
    }
    
    func putPost(_ post: Post, completion: ((Result<[Post]>) -> Void)?) {
        
        var urlComponents = self.commonURLComponents
        urlComponents.path = "/posts"
        urlComponents.queryItems = [URLQueryItem(name: "postId", value: "\(post.id)")]
        
        let request = createURLRequest(urlComponents, "PUT")
        
        self.dataTask(for: request, completion: completion)
    }
    
    func postPost(_ post: Post, completion: ((Result<[Post]>) -> Void)?) {
        
        var urlComponents = self.commonURLComponents
        urlComponents.path = "/posts"
        
        var request = createURLRequest(urlComponents, "POST")
        
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        do {
            let jsonData = try JSONEncoder().encode(post)
            request.httpBody = jsonData
        } catch {
            completion?(.failure(error))
        }
        
        self.dataTask(for: request, completion: completion)
    }
    
    func deletePost(postID: Int, completion: ((Result<[Post]>) -> Void)?) {
        
        var urlComponents = self.commonURLComponents
        urlComponents.path = "/posts"
        urlComponents.queryItems = [URLQueryItem(name: "postId", value: "\(postID)")]
        
        let request = createURLRequest(urlComponents, "DELETE")
        
        self.dataTask(for: request, completion: completion)
    }
    
    // MARK: - Common
    
    var commonURLComponents: URLComponents {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "jsonplaceholder.typicode.com"
        return components
    }
    
    func createURLRequest(_ components: URLComponents, _ method: String) -> URLRequest {
        
        guard let url = components.url else {
            fatalError("Could not create URL from components")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        return request
    }
    
    func dataTask(for request: URLRequest, completion: ((Result<[Post]>) -> Void)?) {
        
        print("URLRequest is: \(request)")
        
        let session = URLSession(configuration: .default)
        
        let singular = request.httpMethod == "POST"
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            DispatchQueue.main.async {
                
                guard error == nil else {
                    completion?(.failure(error!))
                    return
                }
                
                guard let jsonData = data else {
                    let userInfo = [NSLocalizedDescriptionKey : "Data was not retrieved from request"]
                    let dataError = NSError(domain: "", code: 0, userInfo: userInfo) as Error
                    completion?(.failure(dataError))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    
                    var posts = [Post]()
                    
                    if singular {
                        let post = try decoder.decode(Post.self, from: jsonData)
                        posts = [post]
                    } else {
                        posts = try decoder.decode([Post].self, from: jsonData)
                    }
                    
                    completion?(.success(posts))
                    
                } catch {
                    
                    completion?(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Local Storage
    
    var documentsURL: URL {
        
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Could not retrieve documents directory")
        }
        
        return url
    }
    
    @discardableResult func savePostsToDisk() -> Bool {
        
        let path = self.documentsURL.appendingPathComponent("posts").path
        
        guard let data = try? JSONEncoder().encode(self.posts) else {
            fatalError("Could not save self.posts to disk")
        }
        
        return NSKeyedArchiver.archiveRootObject(data, toFile: path)
    }
    
    func loadPostsFromDisk() -> [Post] {
        
        let path = self.documentsURL.appendingPathComponent("posts").path
        
        if let data = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? Data {
            
            if let posts = try? JSONDecoder().decode([Post].self, from: data) {
                return posts
            }
        }
        
        fatalError("Could not decode [Post] from /posts")
    }
}
