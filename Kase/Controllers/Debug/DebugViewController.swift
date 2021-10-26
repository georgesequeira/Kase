//
//  DebugViewController.swift
//  Kase
//
//  Created by George Sequeira on 3/25/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//

import UIKit

class DebugViewController: UIViewController {
    @IBOutlet weak var colView: UICollectionView!
    private var dataManager = DataManager.shared()
    private var debugScreenService = DebugScreenshotAlertService()

    var marks = [Mark]()

    override func viewDidLoad() {
        super.viewDidLoad()
        colView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ScreenshotReuse")
        colView.delegate = self
        colView.dataSource = self

        DispatchQueue.main.async {
            self.marks = self.dataManager.retrieveUnprocessedMarks()
            self.colView.reloadData()
        }
    }
}

extension DebugViewController: ImageCollectionViewCellDelegate {
    func didClickImage(mark: Mark) {
        let debugVC = debugScreenService.alert()
        let trueImage = MarkHelper.loadOriginalImage(mark: mark)
        debugVC.trueImage = trueImage
        self.present(debugVC, animated: true)
    }
}


extension DebugViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return marks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell  {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScreenshotReuse", for: indexPath) as! ImageCollectionViewCell

        let mark = marks[indexPath.row]
        cell.image.image = MarkHelper.loadOriginalImage(mark: mark)!
        cell.delegate = self
        cell.mark = mark

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

