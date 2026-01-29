//
//  MockData.swift
//  Recipe_Tinder
//
//  Created by Sebastian C on 1/28/26.
//

import Foundation

struct MockData {
    
    static let users: [User] = [
        .init(id: NSUUID().uuidString, username: "Mexican Food", profileImageURLS: ["mex_food", "mexFood2"]),
        
        .init(id: NSUUID().uuidString, username: "Italian Food", profileImageURLS: ["pasta", "pasta2"]),
        
        .init(id: NSUUID().uuidString, username: "American Food", profileImageURLS: ["amer1", "amer2"])
        ]
}
