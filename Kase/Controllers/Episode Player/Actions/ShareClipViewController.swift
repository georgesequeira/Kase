//
//  ShareClipViewController.swift
//  Kase
//
//  Created by George Sequeira on 3/9/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//
import AVKit
import UIKit
import MessageUI
import MultiSlider

enum GenerationStatus {
    case running
    case done
    case notRun
    case error
}

class ShareClipViewController: UIViewController {
    @IBOutlet weak var multiSlider: MultiSlider!
    @IBOutlet weak var referenceTime: UILabel!
    @IBOutlet weak var currPlayingmultiSlider: MultiSlider!
    @IBOutlet weak var slideView: UIView!
    @IBOutlet weak var sendMessageButton: UIButton!
    
    var kinletApi = KinletApi()
    var mark: Mark?
    var totalDuration: Int?
    var avPlayer: AVPlayer!
    var currStartTime: Float?
    var currEndTime: Float?
    var episodeId: String?
    var generationStatus = GenerationStatus.notRun
    var clipUrl: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        var totalSeconds: Int16 = 1000
        if let mark = mark {
            totalSeconds = mark.seconds
        }
        let minimumValue = max(0, totalSeconds-30)
        let maximumValue = min(totalDuration!, Int(totalSeconds + 30))

        referenceTime.text = TimestampFormatter().string(from: NSNumber(value: totalSeconds))


        currStartTime = Float(minimumValue)
        currEndTime = Float(maximumValue)
        multiSlider.minimumValue = CGFloat(Float(minimumValue))   // default is 0.0
        multiSlider.maximumValue = CGFloat(Float(maximumValue))   // default is 1.0
        currPlayingmultiSlider.minimumValue = CGFloat(Float(minimumValue))   // default is 0.0
        currPlayingmultiSlider.maximumValue = CGFloat(Float(maximumValue))   // default is 1.0

        multiSlider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged) // continuous changes
        multiSlider.addTarget(self, action: #selector(sliderDragEnded(_:)), for: . touchUpInside) // sent when drag ends
        
        
        // MARK: - round the view
        slideView.layer.cornerRadius = 20
        slideView.layer.masksToBounds = false

        
        currStartTime = Float(max(0, totalSeconds-15))
        currEndTime = Float(min(self.totalDuration!, Int(totalSeconds + 15)))

        currPlayingmultiSlider.tintColor = .blue
        currPlayingmultiSlider.thumbCount = 2

        multiSlider.tintColor = .blue
        multiSlider.thumbCount = 2

        currPlayingmultiSlider.isHidden = true
        currPlayingmultiSlider.snapStepSize = 1
        currPlayingmultiSlider.valueLabelPosition = .top
        currPlayingmultiSlider.isValueLabelRelative = false
        currPlayingmultiSlider.valueLabelFormatter = TimestampFormatter()
        currPlayingmultiSlider.value = [CGFloat(currStartTime!), CGFloat(currEndTime!)]

        multiSlider.snapStepSize = 1
        multiSlider.valueLabelPosition = .bottom
        multiSlider.isValueLabelRelative = false
        multiSlider.valueLabelFormatter = TimestampFormatter()
        multiSlider.value = [CGFloat(currStartTime!), CGFloat(currEndTime!)]
        updateMessageButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        generationStatus = GenerationStatus.notRun
    }

    @IBAction func previewTapped(_ sender: Any) {
        let seekTime = CMTime(value: CMTimeValue(Int(currStartTime!)), timescale: 1)
        // TODO: why this +1 here?
        currPlayingmultiSlider.value = [CGFloat(currStartTime!) + 1]
        currPlayingmultiSlider.isHidden = false
        self.avPlayer.seek(to: seekTime)
        self.avPlayer.play()
        
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let interval =  CMTime(seconds:0.5, preferredTimescale: timeScale)

        generationStatus = GenerationStatus.running
        updateMessageButton()
        kinletApi.createClip(
            attempt:0,
            episodeId: self.episodeId!,
            startTs: Int(self.currStartTime!),
            endTs: Int(self.currEndTime!),
            completionHandler: self.genComplete,
            errorHandler: self.genError)

        self.avPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: {
            (time) in
            // TODO: what is this commented out for?
//            self.currentPlayTime = time
            let seconds = Int(CMTimeGetSeconds(time))
            self.currPlayingmultiSlider.value = [CGFloat(seconds)]
            if Float(seconds) > self.currEndTime! {
                self.currPlayingmultiSlider.isHidden = true
                self.avPlayer.pause()
            }
        })
    }

    func updateMessageButton() {
        DispatchQueue.main.async {
            switch(self.generationStatus) {
            case .running:
                self.sendMessageButton.isEnabled = false
                self.sendMessageButton.tintColor = .darkGray
                self.sendMessageButton.setTitleColor(.darkGray, for: .normal)
                self.sendMessageButton.setTitle("Generating audio", for: .normal)
                if let image = UIImage(systemName: "arrow.clockwise.png") {
                    self.sendMessageButton.setImage(image, for: .normal)
                }
            case .error:
                self.sendMessageButton.isEnabled = false
                self.sendMessageButton.tintColor = .red
                self.sendMessageButton.setTitleColor(.red, for: .normal)
                self.sendMessageButton.setTitle("Error generating audio", for: .normal)
                if let image = UIImage(named: "error") {
                    self.sendMessageButton.setImage(image, for: .normal)
                }
            case .notRun:
                self.sendMessageButton.isEnabled = false
                self.sendMessageButton.tintColor = .darkGray
                self.sendMessageButton.setTitleColor(.darkGray, for: .normal)
                self.sendMessageButton.setTitle("Preview to generate audio", for: .normal)
                if let image = UIImage(systemName: "arrow.clockwise") {
                    self.sendMessageButton.setImage(image, for: .normal)
                }
            case .done:
                self.sendMessageButton.isEnabled = true
                self.sendMessageButton.tintColor = .blue
                self.sendMessageButton.setTitleColor(.blue, for: .normal)
                self.sendMessageButton.setTitle("Send Message", for: .normal)
                if let image = UIImage(systemName: "message") {
                    self.sendMessageButton.setImage(image, for: .normal)
                }
            }
        }
    }

    func genComplete(url: String) {
        self.generationStatus = .done
        self.clipUrl = url
        updateMessageButton()
    }

    func genError(url: String) {
        generationStatus = .error
        updateMessageButton()
    }

    @objc func sliderChanged(_ slider: MultiSlider) {
        currStartTime = Float(slider.value[0])
        currEndTime = Float(slider.value[1])
        self.avPlayer.pause()
        generationStatus = GenerationStatus.notRun
        updateMessageButton()
    }

    @objc func sliderDragEnded(_ slider: MultiSlider) {
        let seekTime = CMTime(value: CMTimeValue(Int(currStartTime!)), timescale: 1)
        self.avPlayer.seek(to: seekTime)
    }

    @IBAction func sendTweet(_ sender: Any) {
        if MFMessageComposeViewController.canSendText() {
            let messageVC = MFMessageComposeViewController()
            messageVC.body = "Hey! I think you might like this podcast clip: " + self.clipUrl!
            messageVC.messageComposeDelegate = self
            self.present(messageVC, animated: true, completion: nil)
        }
    }
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true)
        self.avPlayer?.pause()
    }
}

extension ShareClipViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch(result) {
        case .cancelled:
            dismiss(animated: true, completion: nil)
        case .failed:
            dismiss(animated: true, completion: nil)
        case .sent:
            dismiss(animated: true, completion: nil)
        default :
            print("Message send result: \(result)")
            break
        }
    }
}
