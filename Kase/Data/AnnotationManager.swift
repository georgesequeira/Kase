//
//  ImageProcessing.swift
//  Kase
//
//  Created by George Sequeira on 3/11/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//
import CoreData
import UIKit
import Photos

class ImageAnnotationManager {
    static let shared = ImageAnnotationManager()
    private let defaults = UserDefaults.standard
    private let df = DateFormatter.iSO8601DateWithMillisec
    internal lazy var imageManager = PHCachingImageManager()
    private let elementProcessor = ElementProcessor()
    private var context: NSManagedObjectContext?
    private var dataManager = DataManager.shared()

    deinit {
        print("____ PhotoServiceImpl deinited")
        imageManager.stopCachingImagesForAllAssets()
    }

    private init() {
        df.locale = Locale(identifier: "en_US_POSIX")
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    func getLatestProcessingDate() -> Date {
        let latestProcess = defaults.string(forKey: "LastImageProcessing2")
        if let datestring = latestProcess {
            return df.date(from: datestring)!
        } else {
            return Calendar.current.date(byAdding: .hour, value: -168, to: Date())!
        }
    }

    private func setLatestProcessingDate(date: Date) {
        let val = df.string(from: date)
        defaults.set(val, forKey: "LastImageProcessing2")
    }

    func createNewAnnotations (completion: @escaping () -> Void) {
        // we want to fetch latest photos that we have not seen.
        // we keep track of that by date up to the millisecond with get/set processingDat
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        // TODO: come back and uncomment
//        fetchOptions.predicate = NSPredicate(format: "creationDate > %@", getLatestProcessingDate() as NSDate)

        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        let dispatchGroup = DispatchGroup()

        allPhotos.enumerateObjects { (phasset: PHAsset, count: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            if phasset.mediaSubtypes == .photoScreenshot {
                // only process a photo if it is a screenshot
                dispatchGroup.enter()
                self.processPhoto(phasset: phasset, completion: {
                    dispatchGroup.leave()
                })
            }
        }

        dispatchGroup.notify(queue: DispatchQueue.main) {
                self.setLatestProcessingDate(date: Date())
             completion()
        }
    }

    func processPhoto(phasset: PHAsset, completion: @escaping  () -> Void) {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        let dispatchGroup = DispatchGroup()
        // enter a group as we are going to wait for some asynchronous activity to happen
        dispatchGroup.enter()

        self.imageManager.requestImage(for: phasset, targetSize: CGSize(width: phasset.pixelWidth, height: phasset.pixelHeight), contentMode: .aspectFill, options: options) {
            (image, info) -> Void in
            guard   let info = info,
                    let isImageDegraded = info[PHImageResultIsDegradedKey] as? Int,
                    isImageDegraded == 0 else {
                return }

            let imageId = phasset.localIdentifier.replacingOccurrences(of: "/", with: "--")
            let created = phasset.creationDate

            self.elementProcessor.process(
                imageId: imageId,
                image: image!,
                successCb: { (processingResult) in
                    defer{dispatchGroup.leave()}
                    self.processingDone(created, imageId, image!, processingResult)
                    // do something when the success happens
                },
                errorCb: { (imageId, errorCode) in
                    defer{dispatchGroup.leave()}
                    self.errorProcessing(created, imageId, image!, errorCode)
                })
        }
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }

    func processingDone(_ creation: Date?, _ imageId: String, _ originalImage: UIImage, _ result: ProcessingResult) {
        let episodeName = result.annotatedText.episodeName
        let podcastName = result.annotatedText.podcastName

        var episode = dataManager.retrieveEpisode(podcastName: podcastName, episodeName: episodeName)
        
        if episode == nil {
            episode = dataManager.createEpisode(podcastName: podcastName, episodeName: episodeName)
        }

        dataManager.createMark(
            episode: episode!,
            sec: result.annotatedText.timestamp,
            screenshotId: imageId,
            image: originalImage,
            annotatedImage: result.annotatedImage,
            source: result.source)
    }

    func errorProcessing(_ created: Date?, _ imageId: String, _ originalImage: UIImage, _ error: ElementProcessingErrorCode) {
        if error == .withinKinlet {
            return
        }

        if error == .noTiming {
            return
        }

        let mark = Mark(context: self.context!)
        mark.created = Date()
        mark.notes = ""
        mark.screenshotId = imageId
        mark.seconds = 0
        mark.hadError = true
        mark.errorMsg = "\(error)"
        mark.source = "\(MarkSource.LockScreen)"
        MarkHelper.saveOriginalImage(mark: mark, image: originalImage)

        do{
            print("Saving \(imageId)")
            try self.context!.save()
        } catch {
            print("Could not save annotation \(imageId)")
        }
    }
}
