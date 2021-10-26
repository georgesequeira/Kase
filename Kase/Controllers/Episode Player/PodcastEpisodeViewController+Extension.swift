//
//  PodcastEpisodeViewController+Extension.swift
//  Kase
//
//  Created by George Sequeira on 3/10/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//
import UIKit


extension PodcastEpisodeViewController: ImageCollectionViewCellDelegate {
    func didClickImage(mark: Mark) {
        let debugVC = debugScreenService.alert()
        self.present(debugVC, animated: true)
    }
}


extension PodcastEpisodeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return imageAnnotations.count
        return marks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell  {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScreenshotReuse", for: indexPath) as! ImageCollectionViewCell

        let mark = marks[indexPath.row]
        cell.image.image = MarkHelper.loadOriginalImage(mark: mark)!
        cell.delegate = self
        cell.mark = mark
//        cell.setStatus(status:)

        roundCell(cell: cell)
        return cell
    }

    func roundCell(cell: ImageCollectionViewCell) {
        cell.layer.cornerRadius = 5
        cell.layer.masksToBounds = false
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns : CGFloat =  3
        let width = collectionView.frame.size.width
        let xInsets : CGFloat = 5
        let cellSpacing: CGFloat = 5
        let desiredWidth = (width/columns) - xInsets - cellSpacing

        // Make it the same ratio as the screen
        let screenSize = UIScreen.main.bounds
        let height = ((desiredWidth*screenSize.height)/screenSize.width) - 10

        return CGSize(width: desiredWidth, height: height)
    }

    func runDataStuff(image: UIImage) {
        // parse the image for details
    }
}

extension PodcastEpisodeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

//    func showImagePickerController() {
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.delegate = self
//        imagePickerController.sourceType = .photoLibrary
//        present(imagePickerController, animated: true, completion: nil)
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//            let newImageAnnotation = ImageAnnotation()
//            imageAnnotations.append(newImageAnnotation)
//            newImageAnnotation.saveOriginalImage(image: image)
//            colView.reloadData();
//            self.processAnnotatedPhotos()
//        }
//
//        dismiss(animated: true, completion: nil)
//    }
}

extension PodcastEpisodeViewController {
    // Things related to processing and annotating photos
//    func processAnnotatedPhotos() {
//        DispatchQueue.global(qos: .userInitiated).async {
//            print("Annotation work done")
//            for imageAnnotation in self.imageAnnotations {
//                if imageAnnotation.status == .processing {
//                    self.imageProcessor.process(
//                        in: imageAnnotation.id,
//                        image: imageAnnotation.loadImage()!,
//                        successCb: self.processingDone,
//                        errorCb: self.errorProcessing)
//                }
//            }
//
//            DispatchQueue.main.async {
//                self.colView.reloadData()
//            }
//        }
//    }
//
//    func processingDone(imageId: String, annotation: AnnotationText, annotatedImage: UIImage) {
//        for imageAnnotation in self.imageAnnotations {
//            if imageAnnotation.id == imageId {
//                imageAnnotation.annotatedText = annotation
//                imageAnnotation.saveAnnotatedImage(image: annotatedImage)
//                imageAnnotation.status = .success
//
//                DispatchQueue.main.async {
//                    self.colView.reloadData()
//                }
//            }
//        }
//    }
//
//    func errorProcessing(imageId: String, errorMessage: String) {
//        for imageAnnotation in self.imageAnnotations {
//            if imageAnnotation.id == imageId {
//                imageAnnotation.annotatedText = AnnotationText(
//                    startTime: "",
//                    endTime: "",
//                    podcastName: "",
//                    episodeName: "",
//                    errorMsg: errorMessage,
//                    isError: true)
//                imageAnnotation.status = .error
//
//                DispatchQueue.main.async {
//                    self.colView.reloadData()
//                }
//            }
//        }
//    }
}
