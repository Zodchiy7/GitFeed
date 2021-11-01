//
//  User.swift
//  GitFeed
//
//  Created by Oleg Bondar on 31.10.2021.
//

import Foundation

class User {
    var login: String
    var name: String
    var bio: String
    var imageUrl: URL?
    var action: String
    var publicRepos: Int64
    var publicGists: Int64

    init() {
        login = ""
        name = ""
        bio = ""
        action = ""
        publicRepos = 0
        publicGists = 0
        imageUrl = nil
    }

    // MARK: - JSON -> Event
    init(dictionary: AnyDict) {
        if let gists = dictionary["public_gists"] as? Int64{
            publicGists = gists
        } else {
            publicGists = 0
        }
        if let repos = dictionary["public_repos"] as? Int64{
            publicRepos = repos
        } else {
            publicRepos = 0
        }
        if let actionType = dictionary["type"] as? String{
            action = actionType
        } else {
            action = ""
        }
        if let actorUrlString = dictionary["avatar_url"] as? String,
           let actorUrl = URL(string: actorUrlString){
            imageUrl = actorUrl
        } else {
            imageUrl = nil
        }
        if let actorBio = dictionary["bio"] as? String{
            bio = actorBio
        } else {
            bio = ""
        }
        if let actorName = dictionary["name"] as? String{
            name = actorName
        } else {
            name = ""
        }
        if let loginName = dictionary["login"] as? String {
            login = loginName
        } else {
            login = ""
        }

    }

    // MARK: - Event -> JSON
    var dictionary: AnyDict {
        return [
            "login" : login,
            "name" : name,
            "avatar_url" : imageUrl?.absoluteString ?? "",
            "action" : action,
            "public_repos" : publicRepos,
            "public_gists" : publicGists
        ]
    }
}
