//
//  AlertViewController.swift
//  Kase
//
//  Created by George Sequeira on 2/10/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//

import UIKit

let green = UIColor(red: 0, green: 184/255, blue: 148/255, alpha: 1.0)

class AlertViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var secInput: UITextField!
    @IBOutlet weak var minInput: UITextField!
    @IBOutlet weak var hrInput: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var notesSection: UITextView!
    
    var doneSaving: ((String, Int, Int, Int, String) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        minInput.keyboardType = .numberPad
        hrInput.keyboardType = .numberPad
        secInput.keyboardType = .numberPad

        urlTextField.clearButtonMode = .always

        urlTextField.delegate = self
        // Do any additional setup after loading the view.
        addButton.isEnabled = false
        addButton.backgroundColor = .lightGray
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextField.textDidChangeNotification, object: nil)

        notesSection.textColor = UIColor.lightGray
        notesSection.layer.borderColor = UIColor.darkGray.cgColor
        notesSection.layer.borderWidth = 1
        notesSection.delegate = self
    }

    @objc private func textDidChange(_ notification: Notification) {
        let intHr =  Int(hrInput.text ?? "0") ?? 0
        let intMin = Int(minInput.text ?? "0") ?? 0
        let intSec = Int(secInput.text ?? "0") ?? 0
        let validUrl = validateUrl()

        if intHr + intMin + intSec > 0 {
            if validUrl.0 {
                addButton.isEnabled = true
                addButton.backgroundColor = green
            } else {
                addButton.isEnabled = false
                addButton.backgroundColor = .lightGray
            }
        } else {
            addButton.isEnabled = true
            addButton.backgroundColor = .lightGray
        }
    }

    @IBAction func didTapAdd(_ sender: Any) {
        if let doneSaving = doneSaving {
            let urlField = urlTextField.text!
            
            doneSaving(urlField.components(separatedBy: "?")[0],
                       Int(hrInput.text!) ?? 0,
                       Int(minInput.text!) ?? 0,
                       Int(secInput.text!) ?? 0,
                       notesSection.text)
        }
        dismiss(animated:true)
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func didTapBackground(_ sender: Any) {
        dismiss(animated: true)
    }

    func validateUrl() -> (Bool, String) {
        if urlTextField.text == nil {
            return (false, "")
        }

        let urlString = urlTextField.text!
        
        if urlString.count == 0 {
            return (false, "")
        }

        if urlString.contains("https://open.spotify.") {
                    return (true, "")
        }
        return (false, "Please us the spotify url https://open.spotify... or spotify:episode...")
    }

    func validateInputs() {
        let validUrl = validateUrl()

        if (validUrl.0) {
            addButton.isHidden = false
            addButton.backgroundColor = green
            errorLabel.text = ""
        }
        else {
            errorLabel.text = validUrl.1
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case urlTextField:
                hrInput.becomeFirstResponder()
            default:
                urlTextField.resignFirstResponder()
        }
        validateInputs()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
           case urlTextField:
               hrInput.becomeFirstResponder()
           default:
               urlTextField.resignFirstResponder()
       }
       validateInputs()
    }
}

extension AlertViewController: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if notesSection.textColor == UIColor.lightGray {
            notesSection.text = nil
            notesSection.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if notesSection.text.isEmpty {
            notesSection.text = "Placeholder"
            notesSection.textColor = UIColor.lightGray
        }
    }
}
