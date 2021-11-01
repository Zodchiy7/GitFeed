//
//  GitServices.swift
//  GitFeed
//
//  Created by Oleg Bondar on 30.10.2021.
//

import Foundation
import RxSwift
import RxCocoa
import Kingfisher

class GitServices {

    static let shared = GitServices()

    let base = "https://api.github.com/"
    let repos = "repos/"
    let users = "users/"
    let events = "/events"
    var repoName = "ReactiveX/RxSwift"


    func fetchEvents() -> Observable<[Event]> {
        let response = Observable.from([repoName])
            .map { urlString -> URL in
                return URL(string: self.base + self.repos + urlString + self.events)!
            }
            .map { url -> URLRequest in
                return URLRequest(url: url)
            }
            .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
                return URLSession.shared.rx.response(request: request)
            }
            .share(replay: 1)
        
        return response
            .filter { response, _ in
                return 200..<300 ~= response.statusCode
            }
            .map { _, data -> [[String: Any]] in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                      let result = jsonObject as? [[String: Any]] else {
                    return []
                }
                return result
            }
            .filter { objects in
                return objects.count > 0
            }
            .map { objects in
                return objects.compactMap(Event.init)
            }
    }

    func fetchUser(userName: String) -> Observable<User> {
        let response = Observable.from([userName])
            .map { urlString -> URL in
                return URL(string: self.base + self.users + urlString)!
            }
            .map { url -> URLRequest in
                return URLRequest(url: url)
            }
            .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
                return URLSession.shared.rx.response(request: request)
            }
        
        return response
            .filter { response, _ in
                return 200..<300 ~= response.statusCode
            }
            .map { _, data -> [String: Any] in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                      let result = jsonObject as? [String: Any] else {
                    return [:]
                }
                return result
            }
            .map { object in
                let user = User.init(dictionary: object)
                return user
            }
    }
}
