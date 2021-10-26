//
//  ImageAnnotation.swift
//  Kase
//
//  Created by George Sequeira on 3/10/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//
import UIKit

class ImageAnnotationHelper {
    var id: String
    var createdDataStr: String
    var status: Status
    var annotatedText: AnnotationText?

    var created: Date {
        return DateFormatter.iSO8601DateWithMillisec.date(from: self.createdDataStr)!
    }

    init(id: String, created: Date) {
        self.status = .processing
        self.createdDataStr = DateFormatter.iSO8601DateWithMillisec.string(from: created)
        self.id = id
    }
    

    static func saveOriginalImage(annotation: Annotation, image: UIImage) {
     guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        print(documentsDirectory)
        let fileName = self.id
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
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


    static func saveAnnotatedImage(image: UIImage) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
           print(documentsDirectory)
           let fileName = "\(self.id)-annotated"
           print(fileName)
           let fileURL = documentsDirectory.appendingPathComponent(fileName)
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

    static func loadImage() -> UIImage? {

      let documentDirectory = FileManager.SearchPathDirectory.documentDirectory

        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(self.id)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image

        }

        return nil
    }

    static func loadAnnotationImage() -> UIImage? {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory

        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(self.id + "-annotated")
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
