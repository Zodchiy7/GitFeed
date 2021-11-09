//
//  SearchTableController.swift
//  GitFeed
//
//  Created by Oleg Bondar on 31.10.2021.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class SearchTableController: UITableViewController, UISearchBarDelegate {

    fileprivate let model = Model.shared
    fileprivate let disposeBag = DisposeBag()

    @IBOutlet weak var searchBar: UISearchBar!
    private var filtredEvents = [Event]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self

        searchBar.placeholder = "Search Text"
        setupSearchTextChangeHandling()

    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtredEvents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        
        let event = filtredEvents[indexPath.row]

        cell.textLabel?.text = event.name
        cell.detailTextLabel?.text = event.repo + ", " + event.action.replacingOccurrences(of: "Event", with: "").lowercased()
        cell.imageView?.kf.setImage(with: event.imageUrl, placeholder: UIImage(named: "blank-avatar"))
        
        return cell
    }

}


// MARK: - Search
extension SearchTableController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        tableView.reloadData()
    }
    
}

// MARK: ViewModel
extension SearchTableController {
    
    private func setupSearchTextChangeHandling() {
        self.searchBar
            .rx
            .text
            .orEmpty
            .distinctUntilChanged()
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance) // Ждать 0.5 секунд перед изменением
//            .filter { $0.count > 0 }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [unowned self] (searchText: String) in
                if validate(searchText: searchText) {
                    filtredEvents = model.activeArray().filter({ (event) -> Bool in
                        return
                            event.name.lowercased().contains(searchText.lowercased()) ||
                            event.repo.lowercased().contains(searchText.lowercased()) ||
                            event.imageUrl.relativeString.lowercased().contains(searchText.lowercased())
                    })
                } else {
                    filtredEvents = []
                }
                self.tableView.reloadData()
            } // можно продолжить и сделать асинхронный сетевой запрос
            .disposed(by: disposeBag)
    }

    func validate(searchText: String?) -> Bool {
        guard let text = searchText else {
            return false
        }
        // addition checks
        return text.count > 0
    }

}
