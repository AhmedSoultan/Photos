//
//  NewItemViewController.swift
//  Universal
//
//  Created by Ahmed Sultan on 7/20/19.
//  Copyright © 2019 Ahmed Sultan. All rights reserved.
//

import UIKit
protocol AddNewItem {
    func didCreate(newItem:Item)
}
class NewItemViewController: UIViewController {
    //MARK: - Properties
    var delegate:AddNewItem? = nil
    //MARK: - Outlets
    @IBOutlet weak var itemTextField: UITextField!
    @IBOutlet weak var itemImageView: UIImageView!
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        itemImageView.isUserInteractionEnabled = true
        let saveBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(NewItemViewController.saveBarButtonAction))
        navigationItem.rightBarButtonItem = saveBarButton
        let cancelBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(NewItemViewController.cancelBarButtonAction))
        navigationItem.leftBarButtonItem = cancelBarButton
        title = "Add new item"
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NewItemViewController.imageTappedAction))
        itemImageView.addGestureRecognizer(tapGesture)
    }
    //MARK: - Custom actions
    @objc func saveBarButtonAction() {
        guard let itemName = itemTextField.text,
        !itemName.isEmpty,
        let image = itemImageView.image,
        image != UIImage(named: "placeholder-600x400")
        else {
            let alert = UIAlertController(title: "Error!", message: "please pick an image and insert item name", preferredStyle: .alert)
            let action = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(action)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            return
        }
        saveImageFile(itemName: itemName, itemImage: image) { (fileName) in
            if let fileName = fileName {
                let newItem = Item(name: itemName, imageName: fileName)
                SQLiteManager.shared().insert(newItem: newItem)
                self.delegate?.didCreate(newItem: newItem)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    func saveImageFile(itemName:String, itemImage:UIImage, completion: @escaping (String?) -> Void){
        let documentDirectory = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first!
        let fileName = "\(itemName) \(Date())"
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        if let data = itemImage.jpegData(compressionQuality: 0.1),
            !FileManager.default.fileExists(atPath: fileName){
            do {
                try data.write(to: fileURL)
                completion(fileName)
            }
            catch {
                print("error saving data is \(error)")
                completion(nil)
            }
        }
    }
    @objc func cancelBarButtonAction() {
        dismiss(animated: true)
    }
    @objc func imageTappedAction() {
        let imageSourceAlert = UIAlertController(title: "Image source", message: "Please pick an image source", preferredStyle: UIAlertController.Style.actionSheet)
        let photos = UIAlertAction(title: "Photos", style: UIAlertAction.Style.default) { (_) in
            self.openPhotos()
        }
        imageSourceAlert.addAction(photos)
        let camera = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) { (_) in
            self.openCamera()
        }
        imageSourceAlert.addAction(camera)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        imageSourceAlert.addAction(cancel)
        if let popoverPresentationController = imageSourceAlert.popoverPresentationController {
            popoverPresentationController.sourceView = self.itemImageView
            popoverPresentationController.sourceRect = self.itemImageView.bounds
        }
        DispatchQueue.main.async {
            self.present(imageSourceAlert, animated: true)
        }
    }
    func openPhotos() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        DispatchQueue.main.async {
            self.present(imagePicker, animated: true)
        }
    }
    func openCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        DispatchQueue.main.async {
            self.present(imagePicker, animated: true)
        }
    }
}
extension NewItemViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.itemImageView.image = editedImage
        }
        else if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.itemImageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
}
