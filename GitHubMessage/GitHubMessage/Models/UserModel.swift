//
//  UserModel.swift
//  GitHubMessage
//
//  Created by Yaroslava Hlibochko on 10.05.2021.
//

import Foundation

struct User: Codable, Equatable {
    var id: Int?
    var login: String?
    var avatar_url: String?
    var url: String?
    var isSelected: Bool?
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
