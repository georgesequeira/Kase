//
//  ImageProcessor.swift
//  Kase
//
//  Created by George Sequeira on 3/12/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//

import Firebase

enum ElementProcessingErrorCode {
    case noText
    case withinKinlet
    case noPodcastInfo
    case noTiming
}

struct ProcessingResult {
    let annotatedText: AnnotationText
    let annotatedImage: UIImage
    let source: MarkSource
}

class ElementProcessor {
    let vision = Vision.vision()
    var textRecognizer: VisionTextRecognizer!
      
    init() {
      textRecognizer = vision.onDeviceTextRecognizer()
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error)
            print("issue saving image")
        } else {
            print("Your altered image has been saved to your photos.")
        }
    
}
    // MARK: - This is now being done synchronously instead of async which the textRecognizer can do for us.
    func process(imageId: String,
                 image: UIImage,
                 successCb: @escaping (_ result: ProcessingResult) -> Void,
                 errorCb: @escaping(_ imageId: String,_ errorCode: ElementProcessingErrorCode) -> Void) {
          let croppedImage = getCroppedImage(image: image)!
          let visionImage = VisionImage(image: croppedImage)

          textRecognizer.process(visionImage) { result, error in
            guard error == nil, let result = result, !result.text.isEmpty else {
                errorCb(imageId, ElementProcessingErrorCode.noText)
                return
            }

            // 2
            var blockFrames: [CGRect] = []
            var lineFrames: [CGRect] = []
            var elementFrames: [CGRect] = []
            var elements: [VisionTextElement] = []

            var allText = ""
            // 3
            for block in result.blocks {
              blockFrames.append(block.frame)
              for line in block.lines {
                print(line.text)
                lineFrames.append(line.frame)
                allText = "\(allText) \(line)"
                for element in line.elements {
                  elements.append(element)
                  elementFrames.append(element.frame)
                }
              }
            }

            if allText.lowercased().contains("kinlet") {
                errorCb(imageId, ElementProcessingErrorCode.withinKinlet)
                return
            }

            let annotation = self.retrieveAnnotationText(imageId, elements)

            if let annotationText = annotation {
                if annotationText.episodeName.count < 1 || annotationText.podcastName.count < 1 {
                    errorCb(imageId, ElementProcessingErrorCode.noPodcastInfo)
                    return
                }

                let annotatedImage = self.getImageFromFrame(
                    image: image,
                    blocks: blockFrames,
                    lines: lineFrames,
                    elements: elementFrames)

                successCb(ProcessingResult(annotatedText: annotationText,annotatedImage: annotatedImage, source: .LockScreen))
            } else {
                errorCb(imageId, ElementProcessingErrorCode.noTiming)
            }
          }
    }

    private func retrieveAnnotationText(_ imageId: String, _ elements: [VisionTextElement]) -> AnnotationText? {
        // Sample algorithm
        // - Find the two timestamp elements.
        //   - get the center X
        //   - get the "iphone" that is closest to X
        //   - then find the highest
        // - Work backwords to find the iphone element
        //   - note the timestamps
        // - Start with the iphone element (the last one?)
        
        
        // New algorithm.
        // -- do screen specific grabs.
        var centerX : CGFloat = -1
        
        // reverse it. This is annoying
        let elementsReversed = elements.reversed()


        var startTimestamp = ""
        var endTimestamp = ""

        // find the two timestamps

        for elementLine in elementsReversed.enumerated() {
            let element = elementLine.element
            let ind = elementLine.offset
            print(element.text)
            if (ind+1) >= elementsReversed.count {
                break
            }

            let indInOriginal = (elements.count - 1) - ind
            let nextInOriginal = indInOriginal - 1
            let currText = elements[indInOriginal].text.withoutWhitespace()
            let nextText = elements[nextInOriginal].text.withoutWhitespace()

            if currText.isTimestampLike() && nextText.isTimestampLike() && centerX == -1{
                // cornerPoints goes clockwise from top-left. "2" is bottom right
                // we only need the X of this
                let bottomRightFirstCorner = element.cornerPoints![2].cgPointValue
                let x = bottomRightFirstCorner.x

                let topLeftSecondCorner = elements[indInOriginal].cornerPoints![0].cgPointValue
                let x2 = topLeftSecondCorner.x

                if currText.contains("-") {
                    startTimestamp = nextText
                    endTimestamp = currText
                } else {
                    startTimestamp = currText
                    endTimestamp = nextText
                }
                centerX = (x2+x)/2
            }
        }

        // This is specific to iphone X
        let lowestX = CGFloat(97.0)
        let highestY = CGFloat(283.0)

        var podcastNameStrings: [String] = []
        var firstPodcastElement: VisionTextElement? = nil

        var firstEpisodeElement: VisionTextElement? = nil
        var episodeNameStrings: [String] = []

        for element in elements {
            let bottomRightCorner = element.cornerPoints![2].cgPointValue
            // Too far right
            print(" \(bottomRightCorner.x) \(bottomRightCorner.y) -- \(element.text)")
            if bottomRightCorner.x < lowestX  || bottomRightCorner.y < highestY {
                continue
            }
            
            if firstPodcastElement == nil {
                firstPodcastElement = element
                episodeNameStrings.append(element.text.withoutWhitespace())
                continue
            }
            let firstBottomRight = firstPodcastElement!.cornerPoints![2].cgPointValue

            let currTopLeft = element.cornerPoints![0].cgPointValue
            
            // this is in the second row element
            if currTopLeft.y > firstBottomRight.y {
                if firstEpisodeElement == nil {
                    firstEpisodeElement = element
                    podcastNameStrings.append(element.text.withoutWhitespace())
                    continue
                }

                let secondBottomRight = firstEpisodeElement!.cornerPoints![1].cgPointValue
                if currTopLeft.y > secondBottomRight.y {
                    break
                } else {
                    podcastNameStrings.append(element.text.withoutWhitespace())
                }
            } else {
                // first row!
                episodeNameStrings.append(element.text.withoutWhitespace())
            }
        }
        if startTimestamp.count > 0 {
                return AnnotationText(
                    id: imageId,
                    timestamp: Int16(startTimestamp.totalSecondsFromStr()!),
                    podcastName: podcastNameStrings.joined(separator: " "),
                    episodeName: episodeNameStrings.joined(separator: " "),
                    errorMsg: "",
                    isError: false)
        }

        return nil
    }

    private func getCroppedImage(image: UIImage) -> UIImage? {
        let rect = CGRect(x: CGFloat(22).pointsToPixels(), y: CGFloat(285).pointsToPixels(), width: CGFloat(333).pointsToPixels(), height: CGFloat(90).pointsToPixels())
        UIGraphicsBeginImageContextWithOptions(CGSize(width: rect.size.width , height: rect.size.height ), true, 0.0)
        // MARK: blog post
        image.draw(at: CGPoint(x: -rect.origin.x , y: -rect.origin.y ))
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return croppedImage
    }

    private func getImageFromFrame(image: UIImage, blocks: [CGRect], lines: [CGRect], elements: [CGRect]) -> UIImage {
        let imageSize = image.size
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)

        image.draw(at: CGPoint.zero)

        for line in lines {
            UIColor.red.setStroke()
            UIRectFrame(line)
        }
        for elem in elements {
            UIColor.green.setStroke()
            UIRectFrame(elem)
        }
        for block in blocks {
            UIColor.black.setStroke()
            UIRectFrame(block)
        }

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    // MARK: - private
      
    // 3
    private enum Constants {
      static let lineWidth: CGFloat = 3.0
      static let lineColor = UIColor.yellow.cgColor
      static let fillColor = UIColor.clear.cgColor
    }
}

let validRanges = [
    #"^-?\d{0,1}:\d{2}$"#, // 0:22 or 1:22
    #"^-?\d{2}:\d{2}$"#, // 10:22
    #"^-?\d{1}:\d{2}:\d{2}$"# // 3:41:22
]

extension String {

    func withoutWhitespace() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func isTimestampLike() -> Bool {
        var doesMatch = false
        for validRange in validRanges {
            let result = self.range(of: validRange, options: .regularExpression)
            if result != nil{
                doesMatch = true
                break
            }
        }
        return doesMatch
    }

    private func _matches(for regex: String, in text: String) -> [String] {

        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }.filter {$0.count > 0}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }

    func totalSecondsFromStr() -> Int? {
        if !self.isTimestampLike() {
            return nil
        }

        var totalSeconds = 0
        var numbers = self._matches(for: "-?\\d{0,2}", in: self)

        if numbers.count < 1 {
            return nil
        }
        numbers.reverse()
        
        var currPlace = 0
        for number in numbers {
            totalSeconds += Int(pow(Double(60), Double(currPlace))) * Int(number)!
            currPlace += 1
        }
        return totalSeconds
    }
}


public extension CGFloat {

    
    func pointsToPixels() -> CGFloat {
        return UIScreen.main.scale * self
    }
}
