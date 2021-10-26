//
//  ImageCollectionViewCell.swift
//  Kase
//
//  Created by George Sequeira on 3/10/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//

import UIKit

let lightGray = UIColor(red: 99/255, green: 110/255, blue: 114/255, alpha: 1.0)
let red = UIColor(red: 214/255, green: 48/255, blue: 49, alpha: 1.0)
//let green = UIColor(red: 0, green: 184/255, blue: 148/255, alpha: 1.0)


protocol ImageCollectionViewCellDelegate: AnyObject {
    func didClickImage(mark: Mark)
}


class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    weak var mark: Mark?
    weak var delegate: ImageCollectionViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func screenshotClicked(_ sender: Any) {
        self.delegate?.didClickImage(mark: mark!)
    }
}
