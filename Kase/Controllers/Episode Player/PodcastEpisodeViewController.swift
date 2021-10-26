//
//  PodcastEpisodeViewController.swift
//  Kase
//
//  Created by George Sequeira on 2/16/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//
import AVKit
import UIKit
import CoreData
import Nuke
import SwipeCellKit



class PodcastEpisodeViewController: UIViewController {
    var episodeName: String = "Episode Name";
    var podcastName: String = "Podcast Name";
    var imageUrl: String = "placeholder";
    var episodeUrl: String = "noneFound";
    var player: AVPlayer!
    var episode: Episode!
    var marks = [Mark]()
    var currentPlayTime: CMTime?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let markAlertService = MarkAlertService()
    private let shareclipAlertService = ShareClipAlertService()
    let debugScreenService = DebugScreenshotAlertService()

    private var playerItemContext = 0
    private var totalDuration: CMTime?
    private var dataManager = DataManager.shared()

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    @IBOutlet weak var episodeLabel: UILabel!
    
    // Timing components
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var maxTimeLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var buttonBackground: UIView!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var notesContainerView: UIView!
    @IBOutlet weak var screenshotContainerView: UIView!

    // TableView
    var containerViewController: NotesViewController?
    var screenshotsViewController: ScreenshotsViewController?

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        if player != nil{
            player.pause()
            player?.replaceCurrentItem(with: nil)
            player = nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up slider

        if let markArr = episode.marks {
            marks = markArr.allObjects as! [Mark]
            marks.sort {self.totalSeconds(mark: $0) < self.totalSeconds(mark: $1)}
        }

        // Setting up podcast info
        episodeLabel.text = episode.episodeName ?? "Error on episode"
        showLabel.text = episode.podcastName ?? "Error on name"
        
        let imageURL = URL(string: episode.albumImageUrl!)
        Nuke.loadImage(with: imageURL!, options: ImageLoadingOptions(
          placeholder: UIImage(named: "placeholder"),
          transition: .fadeIn(duration: 0.20)
        ), into: imageView)

        let asset = AVAsset(url: URL(string: episode.episodeUrl!)!)

        let playerItem = AVPlayerItem(asset:asset)

        playerItem.addObserver(self,
            forKeyPath: #keyPath(AVPlayerItem.status),
            options: [.old, .new],
            context: &playerItemContext)
            
        player = setupPlayer(playerItem: playerItem)

        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        // Default state for segmented control
        notesContainerView.alpha = 1
        screenshotContainerView.alpha = 0
        roundButton()
    }

    func roundButton() {
        buttonBackground.layer.cornerRadius = 20
        buttonBackground.layer.masksToBounds = false
        buttonBackground.layer.shadowColor = UIColor.black.cgColor
        buttonBackground.layer.shadowOpacity = 0.7
        buttonBackground.layer.shadowOffset = CGSize(width: 1, height: 1)
        buttonBackground.layer.shadowRadius = 5
    }

    @IBAction func addMark(_ sender: Any) {
        if let currentTime = self.player?.currentItem?.currentTime() {
            let currTimeSeconds = CMTimeGetSeconds(currentTime)
            self.dataManager.createMark(episode: self.episode, sec: Int16(currTimeSeconds), screenshotId: "", image: nil, annotatedImage: nil, source: .InApp)
            if let markArr = self.episode.marks {
                self.marks = markArr.allObjects as! [Mark]
                self.marks.sort {self.totalSeconds(mark: $0) < self.totalSeconds(mark: $1)}
            }
            self.containerViewController?.tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @objc func handleSliderChange() {
        if let duration = player?.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            let value = Float64(slider.value) * totalSeconds
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            player?.seek(to: seekTime, completionHandler: { (completedSeek)
                in
                    
            })
        }
        
    }

    override func observeValue(forKeyPath keyPath: String?,
                           of object: Any?,
                           change: [NSKeyValueChangeKey : Any]?,
                           context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }

        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }

            // Switch over status value
            switch status {
                case .readyToPlay:
                    loadingView.isHidden = true
                    spinner.stopAnimating()
                    spinner.isHidden = true
                    totalDuration = player.currentItem!.asset.duration
                    let seconds = Int(CMTimeGetSeconds(totalDuration!))
                    let secondsString = String(format: "%02d", Int(seconds % 60))
                    let minutesString = String(format: "%02d", Int(seconds / 60))

                    maxTimeLabel.text = String(format: "\(minutesString):\(secondsString)")
                    player.pause()
                case .failed:
                    print(player.error)
                case .unknown:
                    print("what is going on")
            }
        }
    }

    func setupPlayer(playerItem: AVPlayerItem) -> AVPlayer{
        let lPlayer = AVPlayer(playerItem:playerItem)
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let interval =  CMTime(seconds:0.5, preferredTimescale: timeScale)

        lPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: {
            (time) in
            self.currentPlayTime = time
            let seconds = Int(CMTimeGetSeconds(time))
            let secondsString = String(format: "%02d", Int(seconds % 60))
            let minuteString = String(format: "%02d", Int(seconds / 60))
            
            self.currentTimeLabel.text = String(format: "\(minuteString):\(secondsString)")
            
            if let duration = self.player?.currentItem?.duration {
                let durationSeconds = CMTimeGetSeconds(duration)
                self.slider.value = Float(Float64(seconds) / durationSeconds)
            }
        })

        lPlayer.rate = 1.0;
        return lPlayer
    }

    @IBAction func playPodcast(_ sender: Any) {
        player.play()
    }
    
    @IBAction func stopPodcast(_ sender: Any) {
        player.pause()
    }

    func totalSeconds(mark: Mark) -> Int16 {
        return mark.seconds
    }

    func refreshTable() {
        DispatchQueue.main.async {
            self.marks.sort {self.totalSeconds(mark: $0) < self.totalSeconds(mark: $1)}
            self.containerViewController!.tableView.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "notesTableSegue" {
            containerViewController = segue.destination as? NotesViewController
            containerViewController!.delegate = self
            containerViewController!.datasource = self
        }
        if segue.identifier == "screenshotColSegue" {
            screenshotsViewController = segue.destination as? ScreenshotsViewController
            screenshotsViewController!.colViewDelegate = self
            screenshotsViewController!.colViewDatasource = self
        }
        if segue.identifier == "debugSegue" {
            print("something to do here.")
        }
    }

}

extension PodcastEpisodeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return marks.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mark = marks[indexPath.row]

        if let tPlayer = player {
            let seconds = Int64(mark.seconds)
            let seekTime = CMTime(value: seconds, timescale: 1)
            tPlayer.seek(to: seekTime, completionHandler: { (completedSeek)
                in
                    
            })
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mark = marks[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! MarkTableViewCell

        cell.notePreviewLabel.text = "Add notes!"
        if let notes = mark.notes {
            if notes.count > 1 {
                cell.notePreviewLabel.text = mark.notes
            }
        }
        cell.sourceLabel.text = mark.source
        let minutes = String(format:"%02d", mark.seconds / 60)
        let seconds = String(format:"%02d", mark.seconds % 60)
        cell.timeMark.text = String(format:"\(minutes):\(seconds)")
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short

        cell.createdLabel.text = formatter.string(from: mark.created ?? Date())
        cell.delegate = self
        return cell
    }
}

extension PodcastEpisodeViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {
            guard orientation == .left else {
                return nil
            }

            let shareAction = SwipeAction(style: .default, title: "Share") {action, indexPath in
                let markToShare = self.marks[indexPath.row]
                let shareClipVC = self.shareclipAlertService.alert(mark: markToShare, id: self.episode.id!, totalDuration: Int(CMTimeGetSeconds(self.totalDuration!)), avPlayer: self.player)

                self.present(shareClipVC, animated: true)
            }

            shareAction.hidesWhenSelected = true
            shareAction.backgroundColor = UIColor(red: 0, green: 184/255, blue: 148/255, alpha: 1.0)
            return [shareAction]
        }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            let deleteAlert = UIAlertController(title: "Delete", message: "Your note will be deleted.", preferredStyle: UIAlertController.Style.alert)
            deleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                let itemToRemove = self.marks[indexPath.row]
                var nsMarkToDelete: NSSet.Element?

                if let episodeMarks = self.episode?.marks {
                    for mark in episodeMarks {
                        if mark as? Mark == itemToRemove{
                            nsMarkToDelete = mark
                        }
                    }
                }

                self.episode.removeFromMarks(nsMarkToDelete as! Mark)
                self.context.delete(nsMarkToDelete as! Mark)
                self.marks.remove(at: indexPath.row)

                do {
                    try self.context.save()
                } catch {
                    print("issue writing data when encoding, \(error)")
                }
                self.refreshTable()
            }))

            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Does nothing on cancel")
            }))

            self.present(deleteAlert, animated: true, completion: nil)
        }
        deleteAction.hidesWhenSelected = true
        deleteAction.backgroundColor = UIColor(red: 214/255, green: 48/255, blue: 49/255, alpha: 1.0)
        deleteAction.image = UIImage(named: "delete")

        let mark = self.marks[indexPath.row]

        let editAction = SwipeAction(style: .default, title: "Edit") {action, indexPath in
            print("edit")
            let markAlertVC = self.markAlertService.alert(doneEditing: {(totalSeconds, notes) in
                mark.seconds = Int16(totalSeconds)
                mark.notes = notes
                
                do {
                    try self.context.save()
                } catch {
                    print("issue writing data when encoding, \(error)")
                }
                self.refreshTable()
            })

            markAlertVC.secValue = Int(mark.seconds % 60)
            markAlertVC.minValue = Int(mark.seconds / 60)
            markAlertVC.notes = mark.notes ?? ""
            if mark.source != "\(MarkSource.InApp)" && MarkHelper.doesAnnotatedImageExist(mark: mark){
                markAlertVC.debugImage = MarkHelper.loadOriginalImage(mark: mark)
            }

            self.present(markAlertVC, animated: true)

        }
        editAction.hidesWhenSelected = true
        editAction.backgroundColor = UIColor(red: 9/255, green: 132/255, blue: 227/255, alpha: 1.0)

        return [deleteAction, editAction]
    }
}

