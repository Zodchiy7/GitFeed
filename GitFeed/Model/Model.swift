//
//  Model.swift
//  GitFeed
//
//  Created by Oleg Bondar on 30.10.2021.
//

import Foundation

import RxSwift
import RxCocoa

final class Model {
  
    static let shared = Model()
    private init() { }
    
    var events = BehaviorRelay<[Event]>(value: [])
    var user = BehaviorRelay<User>(value: User())

    private var farovorit = [Event]()
    private var isFavorit = false
}

extension Model {
    
    func activeArray() -> [Event] {
        if self.isFavorit {
            return self.farovorit
        }
        return self.events.value
    }

    func append(_ newEvents: [Event]) -> Bool {
        var updatedEvents = events.value + newEvents
        if updatedEvents.count > 50 {
          updatedEvents = Array<Event>(updatedEvents.prefix(upTo: 50))
        }
        
        guard updatedEvents.count > 0 else {
            return false
        }

        self.events = BehaviorRelay<[Event]>(value: updatedEvents)
        return true
    }
    
    func updateFavorite(_ eventNew: Event) {
        if eventNew.favorite {
            let farovorit = self.farovorit + [eventNew]
            self.farovorit = farovorit
        } else {
            let farovorit = self.farovorit.filter({ (event) -> Bool in
                return  event.favorite
            })
            self.farovorit = farovorit
        }
    }
    
    func updateUser(_ newUser: User) {
        let new = newUser
        self.user = BehaviorRelay<User>(value: new)
    }

    func updateUser(_ event: Event?) {
        guard let event = event else {
            return
        }
        self.user.value.name = event.name
        self.user.value.imageUrl = event.imageUrl
        self.user.value.login = ""
        self.user.value.action = ""
        self.user.value.bio = ""
        self.user.value.publicGists = 0
        self.user.value.publicRepos = 0
    }

    func swithFavorite() {
        self.isFavorit = !self.isFavorit
    }
    
    func stateFavorite() -> Bool {
        return self.isFavorit
    }
}
