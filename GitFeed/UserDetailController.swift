//
//  UserDetailController.swift
//  GitFeed
//
//  Created by Oleg Bondar on 31.10.2021.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class UserDetailController: UIViewController {

    fileprivate let model = Model.shared
    fileprivate let gitServices = GitServices.shared
    fileprivate let disposeBag = DisposeBag()
    
    var selectedEvent: Event?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var reposLabel: UILabel!
    @IBOutlet weak var gitsLabel: UILabel!
    @IBOutlet weak var favorSwift: UISwitch!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let user = self.model.user.value
        update(user)

        if let event = self.selectedEvent {
            favorSwift.isOn = event.favorite
        } else {
            favorSwift.isOn = false
            favorSwift.isEnabled = false
        }

        subscribeUser()
    }
    
    func subscribeUser() {
        self.model.user
            .asObservable()
            .subscribe(onNext: { [unowned self] user in
                self.processUsers(user)
            })
            .disposed(by: disposeBag)
    }

    func processUsers(_ newUser: User) {
        let user = newUser
        self.model.updateUser(user)
        update(user)
    }
    
    func update(_ newUser: User) {
        let user = newUser
        loginLabel.text = user.login
        nameLabel.text = user.name
        typeLabel.text = user.action
        reposLabel.text = String(describing: user.publicRepos)
        gitsLabel.text = String(describing: user.publicGists)
        bioLabel.text = user.bio
        avatarImage.kf.setImage(with: user.imageUrl, placeholder: UIImage(named: "blank-avatar"))
    }
    
    @IBAction func onFavoriteSwitch(_ sender: Any) {
        guard let event = self.selectedEvent else {
            return
        }
        event.favorite = favorSwift.isOn
        self.model.updateFavorite(event)
    }
}
