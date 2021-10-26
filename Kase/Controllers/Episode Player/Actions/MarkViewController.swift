//
//  MarkViewController.swift
//  Kase
//
//  Created by George Sequeira on 2/18/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//

import UIKit

class MarkViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var textInput: UITextView!
    @IBOutlet weak var secTextField: UITextField!
    @IBOutlet weak var minTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var cancelButton: UIView!
    @IBOutlet weak var saveButton: UIView!
    
    var doneEditing: ((Int, String) -> ())?

    var debugImage: UIImage?
    var secValue = 0;
    var minValue = 0;
    var notes = "";

    override func viewDidLoad() {
        super.viewDidLoad()

        secTextField.keyboardType = .numberPad
        minTextField.keyboardType = .numberPad
        
        textInput.layer.borderColor = UIColor.darkGray.cgColor
        textInput.layer.borderWidth = 1
        textInput.delegate = self
        
        secTextField.text = String(format: "%02d", secValue)
        minTextField.text = String(format: "%02d", minValue)

        if notes != "" {
            textInput.text = notes
        }

        if let image = debugImage {
            imageView.image = image
            imageView.alpha = 1
        }
        roundThings()
    }

    func roundThings() {
        modalView.layer.cornerRadius = 20
        modalView.layer.masksToBounds = true
        
        cancelButton.layer.cornerRadius = 20
        cancelButton.layer.masksToBounds = true
        
        saveButton.layer.cornerRadius = 20
        saveButton.layer.masksToBounds = false
    }

    @IBAction func didTapSave(_ sender: Any) {

        var min = 0
        if let minStr = minTextField.text {
            if minStr != "0" {
                min = Int(minStr) ?? 0
            }
        }
        var sec = 0
        if let secStr = secTextField.text {
            if secStr != "0" {
                sec = Int(secStr) ?? 0
            }
        }
        let totalSec = min * 60 + sec
        if let doneEditing = doneEditing {
            doneEditing(totalSec, textInput.text)
        }
        dismiss(animated: true)
    }

    @IBAction func didTapDelete(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true)
    }

}

extension MarkViewController: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textInput.textColor == UIColor.lightGray {
            textInput.text = nil
            textInput.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textInput.text.isEmpty {
            textInput.text = "Placeholder"
            textInput.textColor = UIColor.lightGray
        }
    }
}
