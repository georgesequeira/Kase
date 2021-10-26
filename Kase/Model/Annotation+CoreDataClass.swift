//
//  Annotation+CoreDataClass.swift
//  
//
//  Created by George Sequeira on 3/12/20.
//
//

import Foundation
import CoreData
import UIKit

@objc(Annotation)
public class Annotation: NSManagedObject {
    var rawImageFilename: String {
        return screenshotId
    }
    
    var annotatedImageFilename: String {
        return "\(screenshotId)-annotated"
    }

    func doesRawImageExist() -> Bool {
        return Annotation._doesImageExist(filename: self.rawImageFilename)
    }
    
    func doesAnnotatedImageExist() -> Bool {
        return Annotation._doesImageExist(filename: self.annotatedImageFilename)
    }

    func saveOriginalImage(image: UIImage) {
        return Annotation._saveImage(image: image, filename: self.rawImageFilename)
    }

    func saveAnnotatedImage(image: UIImage) {
        return Annotation._saveImage(image: image, filename: self.annotatedImageFilename)
    }

    func loadOriginalImage() -> UIImage? {
        return Annotation._loadImage(filename: self.rawImageFilename)
    }
    
    func loadAnnotatedImage() -> UIImage? {
        return Annotation._loadImage(filename: self.annotatedImageFilename)
    }

    private static func _doesImageExist(filename: String) -> Bool {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return false}

        let pathComponent = documentsDirectory.appendingPathComponent(filename)
        let filePath = pathComponent.path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            return true
        } else {
            return false
        }
    }

    private static func _saveImage(image: UIImage, filename: String) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        let fileURL = documentsDirectory.appendingPathComponent(filename)

        guard let data = image.jpegData(compressionQuality: 1) else { return }

        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
           do {
               try FileManager.default.removeItem(atPath: fileURL.path)
               print("Removed old image")
           } catch let removeError {
               print("couldn't remove file at path", removeError)
           }
        }

        do {
            try data.write(to: fileURL)
        } catch let error {
           print("error saving file with error", error)
        }
    }

    static func _loadImage(filename: String) -> UIImage? {
      let documentDirectory = FileManager.SearchPathDirectory.documentDirectory

      let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
      let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

      if let dirPath = paths.first {
        let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(filename)
        let image = UIImage(contentsOfFile: imageUrl.path)
        return image

      }
      return nil
    }
}

extension DateFormatter {
    static var iSO8601DateWithMillisec: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss.SSS"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }
}
