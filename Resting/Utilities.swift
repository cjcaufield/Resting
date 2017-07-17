//
//  Utilities.swift
//  Resting
//
//  Created by Colin Caufield on 2017-07-15.
//  Copyright © 2017 Secret Geometry, Inc. All rights reserved.
//

import Foundation

enum Result<Value> {
    case success(Value)
    case failure(Error)
}

enum HTTPMethod {
    case get
    case put
    case post
    case delete
}

func currentTimeString() -> String {
    
    let date = Date()
    let calendar = Calendar.current
    
    let hour = calendar.component(.hour, from: date)
    let minutes = calendar.component(.minute, from: date)
    let seconds = calendar.component(.second, from: date)
    
    return "hours = \(hour):\(minutes):\(seconds)"
}
