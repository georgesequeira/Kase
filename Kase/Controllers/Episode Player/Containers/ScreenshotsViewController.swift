//
//  ScreenshotsViewController.swift
//  Kase
//
//  Created by George Sequeira on 3/10/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//

import UIKit

class ScreenshotsViewController: UIViewController {
    @IBOutlet weak var colView: UICollectionView!
    
    var colViewDelegate: UICollectionViewDelegate?
    var colViewDatasource: UICollectionViewDataSource?

    private lazy var photoLibrary = PhotoService()

    override func viewDidLoad() {
        super.viewDidLoad()
        colView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ScreenshotReuse")
        if let delegate = colViewDelegate {
            colView.delegate = delegate
        }
        if let datasource = colViewDatasource {
            colView.dataSource = datasource
        }

    }
}
