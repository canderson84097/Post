//
//  Post.swift
//  Post
//
//  Created by Chris Anderson on 11/18/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import Foundation

struct TopLevelObject: Codable {
    let posts: [Post]
}

struct Post: Codable {
    var text: String
    var timestamp: TimeInterval
    var username: String
    
    var queryTimestamp: Double {
        let timeInterval = (self.timestamp) - 0.00001
        return timeInterval
    }
    
    init(text: String, timestamp: TimeInterval = Date().timeIntervalSince1970, username: String) {
        
        self.text = text
        self.timestamp = timestamp
        self.username = username
    }
}
