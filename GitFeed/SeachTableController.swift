//
//  SeachTableController.swift
//  GitFeed
//
//  Created by Oleg Bondar on 31.10.2021.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class SeachTableController: UITableViewController, UISearchBarDelegate {

    fileprivate let model = Model.shared
    fileprivate let disposeBag = DisposeBag()

    @IBOutlet weak var searchBar: UISearchBar!
    private var filtredEvents = [Event]()
    private var isEmptySearchBar: Bool {
        guard let text = searchBar.text else {
            return false
        }
        return text.isEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self

        searchBar.placeholder = "Search Text"
        searchBar.rx.text
            .orEmpty
            .subscribe { [unowned self] (searchText: String) in
                filtredEvents = model.activeArray().filter({ (event) -> Bool in
                    return
                        event.name.lowercased().contains(searchText.lowercased()) ||
                        event.repo.lowercased().contains(searchText.lowercased()) ||
                        event.imageUrl.relativeString.lowercased().contains(searchText.lowercased())
                })
                self.tableView.reloadData()
            } // можно продолжить и сделать асинхронный сетевой запрос
            .disposed(by: disposeBag)

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
extension SeachTableController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        tableView.reloadData()
    }
    
}
