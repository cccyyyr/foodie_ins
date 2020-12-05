//
//  PostController.swift
//  foodie_ins
//
//  Created by Cathy Chen on 2020/12/3.
//

import UIKit

import AWSS3
import AWSCore
import Firebase
protocol AddPostDelegate: class {
    func didCreate(_ post: Post)
}
class AddRecipeViewController: UIViewController {
    
}

class AddRestaurantViewController: UIViewController {
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var preview: UIImageView!
    @IBOutlet weak var restaurant: UITextField!
    @IBOutlet weak var caption: UITextField!
    var userName: String?
    var handle: Any?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // [START auth_listener]
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
          // [START_EXCLUDE]
            self.userName = user?.uid
          // [END_EXCLUDE]
        }
      }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // [START remove_auth_listener]
        Auth.auth().removeStateDidChangeListener(handle! as! NSObjectProtocol)
        // [END remove_auth_listener]
    }
    var imageURL: String = "https://www.nps.gov/common/uploads/structured_data/3C7D2FBB-1DD8-B71B-0BED99731011CFCE.jpg"
    var uploadCompletionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    override func viewDidLoad() {
        super.viewDidLoad()
        preview.image = UIImage.init(systemName: "plus")
        preview.tintColor =  UIColor.gray
    }
    @IBAction func addPic(_ sender: Any) {
        showChooseSourceTypeAlertController()
    }
    
    @IBAction func savePost(_ sender: Any) {
        if restaurant.hasText && caption.hasText{
            let newPost = Post(userName: self.userName ?? "Annoymous", caption: caption.text!, pic: imageURL, location: restaurant.text!)
            save(p: newPost)
        }
        
    }
    func save(p: Post){
        let simplified:NSMutableDictionary = ["userName": p.userName]
        simplified["caption"] = p.caption
        simplified["imageURL"] = p.pic
        simplified["location"] = p.location
        let db = Firestore.firestore()
        db.collection("posts").addDocument(data: simplified as! [String : Any])
    }
}


extension AddRestaurantViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showChooseSourceTypeAlertController() {
        let photoLibraryAction = UIAlertAction(title: "Choose a Photo", style: .default) { (action) in
            self.showImagePickerController(sourceType: .photoLibrary)
        }
        let cameraAction = UIAlertAction(title: "Take a New Photo", style: .default) { (action) in
            self.showImagePickerController(sourceType: .camera)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        AlertService.showAlert(style: .actionSheet, title: nil, message: nil, actions: [photoLibraryAction, cameraAction, cancelAction], completion: nil)
    }
    
    func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = sourceType
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.preview.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.preview.image = originalImage
        }
        //upload()
        dismiss(animated: true, completion: nil)
    }
//    func upload(){
//        AWSS3Manager.shared.uploadImage(image: self.preview.image!, completion:{ (uploadedFileUrl, error) in
//                if let finalPath = uploadedFileUrl as? String { // 3
//                    self.imageURL = finalPath
//                } else {
//                    print("\(String(describing: error?.localizedDescription))") // 4
//                }
//        })
//    }
}


