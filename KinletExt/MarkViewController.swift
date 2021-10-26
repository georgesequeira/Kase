//
//  MarkViewController.swift
//  KinletExt
//
//  Created by George Sequeira on 3/2/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import MobileCoreServices
import ReplayKit

let green = UIColor(red: 0, green: 184/255, blue: 148/255, alpha: 1.0)

//MARK: - Test episode
// https://open.spotify.com/episode/25hvWi1ldy7Hch7rdK1VvF?si=aB71_TF6QYybsDU8avgEuw
class MarkViewController: UIViewController {
    @IBOutlet weak var secTextField: UITextField!
    @IBOutlet weak var minTextField: UITextField!
    @IBOutlet weak var notesSection: UITextView!
    @IBOutlet weak var addButton: UIButton!

    // MARK: - Core Data stack
    lazy var persistentContainer: NSCustomPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSCustomPersistentContainer(name: "DataModel")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    var spotifyUrl : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        minTextField.keyboardType = .numberPad
        secTextField.keyboardType = .numberPad


        notesSection.delegate = self
        // Do any additional setup after loading the view.
//        addButton.isEnabled = false
//        addButton.backgroundColor = .lightGray
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextField.textDidChangeNotification, object: nil)

        notesSection.textColor = UIColor.lightGray
        notesSection.layer.borderColor = UIColor.darkGray.cgColor
        notesSection.layer.borderWidth = 1
        notesSection.delegate = self
        //MARK: Buttons should be rounded

        if let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] {
           for attachment in extensionItems[0].attachments as! [NSItemProvider] {
               if attachment.canLoadObject(ofClass: URL.self) {
                   attachment.loadObject(ofClass: URL.self) { (data, error) in
                    guard let urlData = data else { return }
                    self.spotifyUrl = urlData.absoluteString.components(separatedBy: "?")[0]
                        print("found spotify url")
                    }
                   }
               }
           }
    }

    @objc private func textDidChange(_ notification: Notification) {
        let intMin = Int(minTextField.text ?? "0") ?? 0
        let intSec = Int(secTextField.text ?? "0") ?? 0
        // do something with this later
    }

    @IBAction func cancelPressed(_ sender: Any) {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    @IBAction func addPressed(_ sender: Any) {
        let context = self.persistentContainer.viewContext
        
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            return
        }

        let newMark = Mark(context: context)
        newMark.hour = 0
        newMark.minute = Int16(minTextField.text ?? "0") ?? 0
        newMark.second = Int16(secTextField.text ?? "0") ?? 0
        
        let notes = notesSection.text

        if notes != nil {
            if notes!.contains("Placeholder") || notes!.count == 0 {
                newMark.notes = "No note written..."
            }else {
                newMark.notes = notes
            }
        }
        newMark.created = Date()

        let content = extensionItems[0]

        // test with this friend: https://open.spotify.com/track/475lkHIj7WqnoXMvN0Xyob?si=IiPDUWR-TAq4LSLGxa94pQ

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Episode")
        request.predicate = NSPredicate(format: "spotifyUrl == %@", spotifyUrl!)

        request.returnsObjectsAsFaults = true
        var episodeExists = false
        do {
            let result = try context.fetch(request)
            for episode in result as! [Episode] {
                episode.marks?.adding(newMark)
                newMark.episode = episode
                episodeExists = true
            }
            if !episodeExists {
                  let newEpisode = Episode(context: context)
                  newEpisode.podcastName = ""
                  newEpisode.episodeName = ""
                  newEpisode.albumImageData = nil
                  newEpisode.episodeUrl = ""
                  newEpisode.spotifyUrl = spotifyUrl!
                  newEpisode.marks = [newMark]
                  newEpisode.loaded = false
            }
            try! context.save()

            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        } catch {
            print("had an error: \(error)")
        }
    }
}

extension MarkViewController: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if notesSection.textColor == UIColor.lightGray {
            notesSection.text = nil
            notesSection.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if notesSection.text.isEmpty {
            notesSection.text = "Placeholder.."
            notesSection.textColor = UIColor.lightGray
        }
    }
}
