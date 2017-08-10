//
//  Basic.swift
//  Resting
//
//  Created by Colin Caufield on 2017-07-24.
//  Copyright © 2017 Secret Geometry, Inc. All rights reserved.
//

import Foundation

func testGet() {
    
    var components = URLComponents()
    components.scheme = "https"
    components.host = "jsonplaceholder.typicode.com"
    components.path = "/posts"
    components.queryItems = [URLQueryItem(name: "userID", value: "1")]
    
    guard let url = components.url else {
        print("Couldn't create URL from components.")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    let session = URLSession(configuration: .default)
    
    let dataTask = session.dataTask(with: request) { (data, response, error) in
        
        DispatchQueue.main.async {
            
            if error != nil {
                print("Received error: \(error!)")
                return
            }
            
            guard let jsonData = data else {
                print("Data wasn't received.")
                return
            }
            
            print("Response succesfully received.")
            print("Data is: \(jsonData)")
            
            let decoder = JSONDecoder()
            var posts = [Post]()
            
            do {
                posts = try decoder.decode([Post].self, from: jsonData)
            }
            catch {
                print("Couldn't create Posts from JSON data.")
                return
            }
            
            print("Posts decoded:")
            for post in posts {
                print(post)
            }
        }
    }
    
    dataTask.resume()
}

func testPost() {
    
    var components = URLComponents()
    components.scheme = "https"
    components.host = "jsonplaceholder.typicode.com"
    components.path = "/posts"
    
    guard let url = components.url else {
        print("Couldn't create URL from components.")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    var headers = request.allHTTPHeaderFields ?? [:]
    headers["Content-Type"] = "application/json"
    request.allHTTPHeaderFields = headers
    
    let newPost = Post(userId: 1,
                       id: 999,
                       title: "HELLO WORLD at \(time)",
                       body: "How are you all today?")
    
    do {
        let jsonData = try JSONEncoder().encode(newPost)
        request.httpBody = jsonData
    } catch {
        print("Couldn't encode Post into JSON.")
        return
    }
    
    let session = URLSession(configuration: .default)
    
    let task = session.dataTask(with: request) { (data, response, error) in
        
        DispatchQueue.main.async {
            
            if error != nil {
                print("Error: \(error!)")
                return
            }
            
            guard let jsonData = data else {
                print("Data not received.")
                return
            }
            
            print("Response successfully received.")
            
            let decoder = JSONDecoder()
            var post: Post?
            
            do {
                post = try decoder.decode(Post.self, from: jsonData)
            }
            catch {
                print("Couldn't decode json data.")
                return
            }
            
            print("Post successfully decoded:")
            print(post!)
        }
    }
    
    task.resume()
}
