//
//  Post.swift
//  Resting
//
//  Created by Colin Caufield on 2017-07-15.
//  Copyright © 2017 Secret Geometry, Inc. All rights reserved.
//

struct Post: Codable {
    
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

