//
//  BookmarksViewController.swift
//  Kase
//
//  Created by George Sequeira on 2/8/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//
import CoreData
import UIKit
import SwipeCellKit
import Nuke


class LikesViewController: UIViewController {
    private var annotationManager = ImageAnnotationManager.shared
    private let refreshControl = UIRefreshControl()

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let dataManager = DataManager.shared()

    @IBOutlet weak var buttonBackground: UIView!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Kinlet"
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: "ClipTableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        tableView.rowHeight = 120
        setupTableView()

        refreshControl.attributedTitle = NSAttributedString(string: "Updating data.")
        roundButton()

        #if TARGET_OS_SIMULATOR
            buttonBackground.isHidden = false
        #else
            buttonBackground.isHidden = true
        #endif
        refreshControl.beginRefreshing()
        DispatchQueue.main.async {
            self.dataManager.refreshEpisodeInformation {
                print("Finished refreshing episode information!")
                self.loadEpisodes()
            }

            self.annotationManager.createNewAnnotations() { () in
                print("finished at \(Date())")
                self.dataManager.refreshEpisodeInformation {
                    print("Finished refreshing episode information!")
                    self.loadEpisodes()
                }
                
            }
        }
    }

    func roundButton() {
        buttonBackground.layer.cornerRadius = 20
        buttonBackground.layer.masksToBounds = false
        buttonBackground.layer.shadowColor = UIColor.black.cgColor
        buttonBackground.layer.shadowOpacity = 0.7
        buttonBackground.layer.shadowOffset = CGSize(width: 1, height: 1)
        buttonBackground.layer.shadowRadius = 5
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        // not sure what else to do here
    }

    private func setupTableView() {
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.backgroundView = refreshControl
        }
        refreshControl.addTarget(self, action: #selector(refreshMarks(_:)), for: .valueChanged)
    }

    @objc private func refreshMarks(_ sender: Any) {
        // Fetch Weather Data
        print("Getting new marks")
        loadEpisodes()
    }

    func loadEpisodes() {
        print("Here we are.")
        DispatchQueue.main.async {
            // TODO: Come back and figure out what work needs to be done here
            self.tableView.reloadData()
            if self.refreshControl.isRefreshing
            {
                self.refreshControl.endRefreshing()
            }
        }
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        // TODO: come back and add functionaity when add is working (so that we can allow for photo roll updates.
//        let alertVC = alertService.alert(addUrl: self.addUrl)
//        present(alertVC, animated: true)
    }
}

extension LikesViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {return nil}
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            let itemToRemove = self.dataManager.episodes[indexPath.row]
            self.dataManager.deleteEpisode(episode: itemToRemove)
            // TODO: make sure annotations get deleted too
            self.tableView.reloadData()
        }

        deleteAction.hidesWhenSelected = true
        deleteAction.image = UIImage(named: "delete")

        return [deleteAction]
    }

}

extension LikesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.dataManager.episodes.count
        return count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.dataManager.episodes[indexPath.row]
        if episode.loaded && !episode.error {
            performSegue(withIdentifier: "selectPodcastEpisodeSegue", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! PodcastEpisodeViewController
        

        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.episode = self.dataManager.episodes[indexPath.row]
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let episode = self.dataManager.episodes[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! ClipTableViewCell
        var podcastName = episode.podcastName ?? ""
        if podcastName.count == 0 {
            podcastName = episode.episodeUrl ?? "EpisodeUrl not found"
        }
        var podcastEpisodeName = episode.episodeName ?? ""
        if podcastEpisodeName.count == 0 {
            podcastEpisodeName = "Loading from kinlet..."
        }
        cell.podcastName.text = podcastName
        cell.podcastEpisodeName.text = podcastEpisodeName
        let markCount = episode.marks?.count ?? 0
        var txt = "\(markCount) marks"
        cell.marksLabel.layer.borderColor = UIColor.lightGray.cgColor
        cell.marksLabel.layer.borderWidth = 0.25
        cell.marksLabel.layer.cornerRadius = 1
        if markCount == 1 {
            txt = "1 mark"
        }

        cell.marksLabel.text = txt

        if let albumUrl = episode.albumImageUrl{
            if albumUrl.count > 0 {
                let imageURL = URL(string: albumUrl)
                Nuke.loadImage(with: imageURL!, options: ImageLoadingOptions(
                  placeholder: UIImage(named: "placeholder"),
                  transition: .fadeIn(duration: 0.20)
                ), into: cell.albumView)
            }
        }
        cell.delegate = self
        return cell
    }
}
