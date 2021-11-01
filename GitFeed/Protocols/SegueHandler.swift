//
//  SegueHandler.swift
//  GitFeed
//
//  Created by Oleg Bondar on 31.10.2021.
//

import UIKit

protocol SegueHandler {
    associatedtype SegueIdentifier: RawRepresentable
}

extension SegueHandler //Default implementation...
    where Self: UIViewController, //for view controllers...
          SegueIdentifier.RawValue == String { //who have String segue identifiers.
    func performSegue(withIdentifier identifier: SegueIdentifier, sender: AnyObject? = nil) {
        performSegue(withIdentifier: identifier.rawValue, sender: sender)
    }

    func identifier(forSegue segue: UIStoryboardSegue) -> SegueIdentifier {
        guard
            let stringIdentifier = segue.identifier,
            let identifier = SegueIdentifier(rawValue: stringIdentifier)
        else {
            fatalError("Couldn't find identifier for segue!")
        }

        return identifier
    }
}
