//
//  NotesViewController.swift
//  Kase
//
//  Created by George Sequeira on 3/10/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var delegate: UITableViewDelegate?
    var datasource: UITableViewDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "MarkTableViewCell", bundle: nil), forCellReuseIdentifier: "NoteCell")
        tableView.rowHeight = 85
        tableView.delegate = delegate
        tableView.dataSource = datasource
    }
}
