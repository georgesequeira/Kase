//
//  Episode.swift
//  Kase
//
//  Created by George Sequeira on 3/12/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//
import CoreData
import UIKit

class DataManager {
    static let _dm = DataManager()
    let context: NSManagedObjectContext
    var episodes = [Episode]()
    var marks = [Mark]()
    let taskManager = TaskManager()

    class func shared() -> DataManager{
        return _dm
    }
    
    private init() {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    func deleteEpisode(episode: Episode) {
        self.context.delete(episode)
        episodes = episodes.filter {$0 != episode}
        do {
            try self.context.save()
        } catch {
            print("issue writing data when encoding, \(error)")
        }
    }

    func retrieveUnprocessedMarks() -> [Mark]{
        let markrequest : NSFetchRequest<Mark> = Mark.fetchRequest()
        markrequest.predicate = NSPredicate(format: "hadError == YES")
        do{
            return try context.fetch(markrequest)
        }catch{
            print("Error fetching data from context \(error)")
            return []
        }
    }

    func refreshEpisodeInformation(completion: @escaping() -> Void) {
        let markrequest: NSFetchRequest<Mark> = Mark.fetchRequest()

        do{
            marks = try context.fetch(markrequest)
        }catch{
            print("Error fetching data from context \(error)")
            marks = []
            episodes = []
        }

        let request: NSFetchRequest<Episode> = Episode.fetchRequest()
        // TODO: Sort this in ascending date order
//        let sort = NSSortDescriptor(key: #keyPath(Episode.date), ascending: true)
//        fetchRequest.sortDescriptors = [sort]
        do{
            episodes = try context.fetch(request)
        }catch{
            print("Error fetching data from context \(error)")
            episodes = []
        }

        print(episodes.count)

        let dispatchGroup = DispatchGroup()

        for episode in episodes {
            dispatchGroup.enter()
            let episodeName = episode.rawEpisodeName!
            let podcastName = episode.rawPodcastName!
            if !episode.loaded || episode.loaded{
                taskManager.getData(
                    episodeName: episodeName,
                    podcastName: podcastName,
                    completionHandler: {(podcastInfo: PodcastInformation) in
                        defer { dispatchGroup.leave() }
                        self.handlePodcastInfo(podInfo: podcastInfo)
                    },
                    errorHandler: {(url: String) in
                        defer {dispatchGroup.leave()}
                        self.handleErrorOnFetch(url: url)})
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }

    func retrieveEpisode(podcastName: String, episodeName: String) -> Episode? {
        let fetchRequest: NSFetchRequest<Episode> = Episode.fetchRequest()
        var subPredicates : [NSPredicate] = []
        subPredicates.append(NSPredicate(format: "rawPodcastName == %@", podcastName))
        subPredicates.append(NSPredicate(format: "rawEpisodeName == %@", episodeName))

        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: subPredicates)

        do {
            return try context.fetch(
                fetchRequest).first
        }
        catch {
            print("error executing fetch request: \(error)")
        }

        return nil
    }

    func createEpisode(podcastName: String, episodeName: String) -> Episode {
        let newEpisode = Episode(context: context)
        newEpisode.rawPodcastName = podcastName
        newEpisode.rawEpisodeName = episodeName
        newEpisode.podcastName = ""
        newEpisode.episodeName = ""
        newEpisode.albumImageUrl = nil
        newEpisode.episodeUrl = ""
        newEpisode.spotifyUrl = ""
        newEpisode.marks = []
        newEpisode.loaded = false
        newEpisode.id = ""

        if context.hasChanges {
            do {
                try context.save()
                episodes.append(newEpisode)
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        return newEpisode
    }
    
    func createMark(episode: Episode, sec: Int16, screenshotId: String, image: UIImage?, annotatedImage: UIImage?, source: MarkSource) {
        
        if let currMarks = episode.marks {
            for currMark in currMarks {
                let currMarkMark = currMark as! Mark
                if currMarkMark.seconds == sec {
                    return
                }
            }
        }

        let mark = Mark(context: self.context)
        mark.seconds = sec
        mark.notes = ""
        mark.screenshotId = screenshotId
        mark.created = Date()
        mark.episode = episode
        mark.source = "\(source)"
        if source != .InApp && image != nil  && annotatedImage != nil{
            MarkHelper.saveOriginalImage(mark: mark, image: image!)
            MarkHelper.saveAnnotatedImage(mark: mark, image: annotatedImage!)
        }

        if context.hasChanges {
            do {
                episode.marks?.adding(mark)
                print(episode.marks?.count)
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func handleErrorOnFetch(url: String) {
        for episode in episodes {
            if url.contains(episode.spotifyUrl!) {
                episode.episodeName = "Name is different"
                episode.podcastName = "Load from kinlet failed.."
                episode.loaded = true
                episode.error = true
                break;
            }
        }
        DispatchQueue.main.async {
            do{
                try self.context.save()
            }catch{
                print("Error saving on handle error on fetch: \(error)")
            }
        }
    }

    func handlePodcastInfo(podInfo: PodcastInformation) {
        let allEpisodes = episodes

        for episode in episodes {
            print(episodes.count)
            print(episode)
            print(episode.episodeName)
            print(episode.podcastName)
            print(episode.error)
            let episodeName = episode.rawEpisodeName!

            print(episodeName)
            print(podInfo.episode_name)
            if episodeName == podInfo.partial_episode_name {
                episode.id = podInfo.id
                episode.episodeName = podInfo.episode_name
                episode.podcastName = podInfo.podcast_name
                episode.albumImageUrl = podInfo.image_url
                episode.episodeUrl = podInfo.audio_url
                episode.loaded = true
                episode.error = false
                break;
            }
        }

        DispatchQueue.main.async {
            do{
                try self.context.save()
            }catch{
                print("Error saving on handle podcast info on fetch: \(error)")
            }
        }
    }
}

