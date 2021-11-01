//
//  ActivityTableViewController.swift
//  GitFeed
//
//  Created by Oleg Bondar on 30.10.2021.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class EventsTableController: UITableViewController {

    fileprivate let model = Model.shared
    fileprivate let gitServices = GitServices.shared
    fileprivate let disposeBag = DisposeBag()
    
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    private var selectedUser: String = ""
    private var selectedEvent: Event?
    private let searchController = UISearchController(searchResultsController: nil)
    private var filtredEvents = [Event]()
    private var isEmptySearchBar: Bool {
        guard let text = searchController.searchBar.text else {
            return false
        }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !isEmptySearchBar
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        title = gitServices.repoName
        
        //Setup the Serch Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Text"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        self.refreshControl = UIRefreshControl()
        let refreshControl = self.refreshControl!

        refreshControl.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        refreshControl.tintColor = UIColor.darkGray
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        imageFavoriteButton()
        
        refresh()
    }

    @objc func refresh() {
        fetchEvents()
        subscribeEvents()
    }

    func fetchEvents() {
        self.gitServices.fetchEvents()
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: self.model.events)
            .disposed(by: disposeBag)
    }
    
    func processEvents(_ newEvents: [Event]) {
        if self.model.append(newEvents) {
            refreshControl?.endRefreshing()
        }
        tableView.reloadData()
    }
    
    func subscribeEvents() {
        self.model.events
            .asObservable()
            .subscribe(onNext: { [unowned self] newEvents in
                self.processEvents(newEvents)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filtredEvents.count
        }
        return self.model.activeArray().count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        
        var event: Event
        if isFiltering {
            event = filtredEvents[indexPath.row]
        } else {
            event = self.model.activeArray()[indexPath.row]
        }

        cell.textLabel?.text = event.name
        cell.detailTextLabel?.text = event.repo + ", " + event.action.replacingOccurrences(of: "Event", with: "").lowercased()
        cell.imageView?.kf.setImage(with: event.imageUrl, placeholder: UIImage(named: "blank-avatar"))
        
        return cell
    }

}


// MARK: - SegueHandler
extension EventsTableController: SegueHandler {
    enum SegueIdentifier: String {
        case GoToUserDetail
        case GoToSeach
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = self.identifier(forSegue: segue)
        switch identifier {
        case .GoToUserDetail:
            guard let userDetailController = segue.destination as? UserDetailController else {
                assertionFailure("Couldn't get User Detail is coming VC!")
                return
            }
            userDetailController.selectedEvent = self.selectedEvent
        case.GoToSeach:
            guard let _ = segue.destination as? SeachTableController else {
                assertionFailure("Couldn't get User Detail is coming VC!")
                return
            }
        }
    }
}


// MARK: - User
extension EventsTableController {
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        var event: Event
        if isFiltering {
            event = filtredEvents[indexPath.row]
        } else {
            event = self.model.activeArray()[indexPath.row]
        }
        selectedEvent = event
        fetchUser(event.name)
        self.model.updateUser(event)
        return indexPath
    }
    
    func fetchUser(_ userName: String) {
        self.gitServices.fetchUser(userName: userName)
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: self.model.user)
            .disposed(by: disposeBag)
    }
    
}

// MARK: - Search
extension EventsTableController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterControlForSearchText(searchController.searchBar.text!)
        tableView.reloadData()
    }
    
    private func filterControlForSearchText(_ searchText: String) {
        filtredEvents = model.activeArray().filter({ (event) -> Bool in
            return
                event.name.lowercased().contains(searchText.lowercased()) ||
                event.repo.lowercased().contains(searchText.lowercased()) ||
                event.imageUrl.relativeString.lowercased().contains(searchText.lowercased())
        })
    }
}

// MARK: - Favorite
extension EventsTableController {
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        self.model.swithFavorite()
        imageFavoriteButton()
        tableView.reloadData()
    }

    func imageFavoriteButton() {
        self.favoriteButton.image = UIImage(systemName: self.model.stateFavorite() ? "star.fill" : "star")
    }
}
