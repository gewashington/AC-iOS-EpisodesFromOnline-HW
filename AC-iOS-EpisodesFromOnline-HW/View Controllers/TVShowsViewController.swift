//
//  ViewController.swift
//  AC-iOS-EpisodesFromOnline-HW
//
//  Created by C4Q  on 11/29/17.
//  Copyright © 2017 C4Q . All rights reserved.
//

import UIKit



/*TO-DO
 - Setting image not available for shows/episodes without images
*/


class TVShowsViewController: UIViewController {
    
    @IBOutlet weak var tvShowsTableView: UITableView!
    @IBOutlet weak var tvShowsSearchBar: UISearchBar!

    
    var TVShows = [TVSeries?]() {
        didSet {
            tvShowsTableView.reloadData()
        }
    }
    
    var searchWord = " " {
        didSet {
            loadData()
        }
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //For navigation bar
        self.navigationItem.title = "TV Shows"
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.barTintColor = UIColor.black
        tvShowsTableView.delegate = self
        tvShowsTableView.dataSource = self
        tvShowsSearchBar.delegate = self
        self.navigationItem.titleView?.sizeToFit()
        tvShowsSearchBar.autocapitalizationType = .none


    }
    

    
    func loadData() {
        let urlStr = "http://api.tvmaze.com/search/shows?q=\(searchWord)"
        let completion: ([TVSeries]) -> Void = { (onlineObject:[ TVSeries]) in
            self.TVShows = onlineObject
        }
        let errorHandler: (Error) -> Void = {(error: Error) in
            print(error)
        }
        TVShowsAPIClient.manager.getTvShows(from: urlStr, completionHandler: completion, errorHandler: errorHandler)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EpisodesViewController {
            destination.tvSerial = TVShows[tvShowsTableView.indexPathForSelectedRow!.row]
        }
    }
}


extension TVShowsViewController: UITableViewDelegate, UITableViewDataSource {
    
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tvShow = TVShows[indexPath.row]
        let cell = tvShowsTableView.dequeueReusableCell(withIdentifier: "TVShowsCell", for: indexPath)
        if let cell = cell as? TVShowsCell {
            cell.seriesTitleLabel?.text = tvShow?.show.name
            cell.seriesRatingLabel?.text = "Rating: \(tvShow?.show.rating?.average?.description ?? "N/A")"
            cell.seriesImageView.image = nil
            //to call image
            guard let imageStr = tvShow?.show.image?.original else { return cell }
            cell.tvShowActivityIndicator.startAnimating()
            guard let urlStr = URL(string: imageStr) else { return cell }
            DispatchQueue.main.async {
                guard let rawImageData = try? Data(contentsOf: urlStr) else {return}
                DispatchQueue.main.async {
                    guard let onlineImage = UIImage(data: rawImageData) else { return }
                    cell.seriesImageView.image = onlineImage
                    cell.setNeedsLayout()
                    cell.tvShowActivityIndicator.stopAnimating()
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TVShows.count
    }
}


extension TVShowsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchWord = tvShowsSearchBar.text ?? " "
        tvShowsTableView.reloadData()
        searchBar.resignFirstResponder()
    }
    

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       searchWord = searchText
        
    }
    
}

