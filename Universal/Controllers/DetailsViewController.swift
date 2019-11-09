//
//  DetailsViewController.swift
//  Universal
//
//  Created by Ahmed Sultan on 7/20/19.
//  Copyright © 2019 Ahmed Sultan. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    //MARK: - Properties
    var item:Item!
    //MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    //MARK: - Custom action
    func updateUI() {
        if item != nil {
            nameLabel.text = item.name
            let documentDirectory = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first!
            let imageURL = documentDirectory.appendingPathComponent(item.imageName)
            let image = UIImage(contentsOfFile: imageURL.path)
            imageView.image = image
        }
    }
}
