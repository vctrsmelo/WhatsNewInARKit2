//
//  ViewController.swift
//  WhatsNewInARKit2
//
//  Created by Victor S Melo on 24/08/18.
//  Copyright © 2018 Victor Melo. All rights reserved.
//

import UIKit
//import SceneKit
import ARKit

protocol MainViewControllerDelegate: class {
    func mainViewControllerDidSelectFlow(_ selectedFlow: String)
}

class MainViewController: UIViewController  {

    
    @IBOutlet weak var tableView: UITableView!
    var cellsTitle: [String]!
    
    weak var delegate: MainViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
}

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellsTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
        cell.textLabel?.text = cellsTitle[indexPath.row]
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let flow = cellsTitle[indexPath.row]
        delegate?.mainViewControllerDidSelectFlow(flow)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
