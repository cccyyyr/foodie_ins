//
//  PostController.swift
//  foodie_ins
//
//  Created by Cathy Chen on 2020/12/3.
//

import UIKit
import SearchTextField
import AWSS3
import AWSCore
import Firebase
import CoreLocation
protocol AddPostDelegate: class {
    func didCreate(_ post: Post)
}
class AddRecipeViewController: UIViewController {
    
}

class AddRestaurantViewController: UIViewController {
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var preview: UIImageView!
    @IBOutlet weak var restaurant: SearchTextField!
    @IBOutlet weak var caption: UITextField!
    var selected: SearchResult?
    var filterRes: [SearchResult] = []
    var shouldPresent: [SearchTextFieldItem] = []
    var currentLoc: CLLocation!
    var userid: String?
    var handle: Any?
    var locationManager = CLLocationManager()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.userid = user?.uid
        }
      }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle! as! NSObjectProtocol)
    }
    var imageURL: String = "https://www.nps.gov/common/uploads/structured_data/3C7D2FBB-1DD8-B71B-0BED99731011CFCE.jpg"
    var uploadCompletionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        self.currentLoc = CLLocation(latitude: CLLocationDegrees(40), longitude: CLLocationDegrees(-75))
//        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
//        CLLocationManager.authorizationStatus() == .authorizedAlways) {
//           currentLoc = locationManager.location
//           print(currentLoc.coordinate.latitude)
//           print(currentLoc.coordinate.longitude)
//        } else {
//            currentLoc = CLLocation(latitude: CLLocationDegrees(40), longitude: CLLocationDegrees(-75))
//        }
        configureAutoSearch()
    }
    @IBAction func addPic(_ sender: Any) {
        showChooseSourceTypeAlertController()
    }
    
    @IBAction func savePost(_ sender: Any) {
        if selected != nil && caption.hasText{
            let newPost = Post(userName: self.userid ?? "Annoymous", caption: caption.text!, pic: imageURL, location: selected!.id)
            updateRestaurant()
            save(p: newPost)
            transitionToHome()
        }
        
    }
    func save(p: Post){
        let simplified:NSMutableDictionary = ["userName": p.userName]
        simplified["caption"] = p.caption
        simplified["imageURL"] = p.pic
        simplified["location"] = p.location
        let db = Firestore.firestore()
        let newPostid = db.collection("posts").addDocument(data: simplified as! [String : Any]).documentID
        let docRef = db.collection("users").document("\(self.userid ?? "Annoymous")")
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var old_posts = document.get("posts") as? [Any]
                old_posts?.append(newPostid)
                docRef.updateData(["posts" : old_posts!])
            } else {
                print("can't find document \(self.userid ?? "annoymous")")
            }
        }
        
    }
    func updateRestaurant(){
        let db = Firestore.firestore()
        db.collection("restaurants").document("\(self.selected!.id)").setData(["name": self.selected!.title])
    }
    func transitionToHome() {
        self.performSegue(withIdentifier: "backtohome", sender: addButton)
//        let homeViewController = storyboard?.instantiateViewController(identifier: "TabVC") as? FeedController
//        
//        view.window?.rootViewController = homeViewController
//        view.window?.makeKeyAndVisible()
        
    }
    func configureAutoSearch(){
        restaurant.itemSelectionHandler = { filteredResults, itemPosition in
            // Just in case you need the item position
            let item = filteredResults[itemPosition]
            print("Item at position \(itemPosition): \(item.title)")
            self.restaurant.text = item.title
            self.selected = self.filterRes[itemPosition]
        }
        
        restaurant.userStoppedTypingHandler = {
            if let criteria = self.restaurant.text {
                if criteria.count > 1 {
                    self.restaurant.showLoadingIndicator()
                    self.getList()
                    self.fillShouldPresent()
                    self.restaurant.filterItems(self.shouldPresent)
                    self.restaurant.stopLoadingIndicator()
                    print(self.filterRes)
    
                }
            }
        } as (() -> Void)
    }
    
    func getList(){
        let urlString = "https://api.yelp.com/v3/autocomplete"
        var items = [URLQueryItem]()
        var myURL = URLComponents(string: urlString)
        let searchText = restaurant.text
        let param = ["latitude":String(currentLoc.coordinate.latitude),"longitude":String(currentLoc.coordinate.longitude), "text": searchText]
        for (key,value) in param {
            items.append(URLQueryItem(name: key, value: value))
        }
        myURL?.queryItems = items
        var request =  URLRequest(url: (myURL?.url)!)
        request.setValue("Bearer \(yelp)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                      error == nil else {
                      print(error?.localizedDescription ?? "Response Error")
                      return }
            do{
                print(data)
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let businesses = jsonResponse["businesses"] as! [[String: Any]]
                print("businesses")
                print(businesses)
                self.filterRes = []
                for biz in businesses{
                    print(biz)
                    self.filterRes.append(SearchResult(title: biz["name"] as! String, id: biz["id"] as! String))
                }
                self.fillShouldPresent()
                
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
    }
    public func fillShouldPresent() -> Bool{
        self.shouldPresent = []
        for res in self.filterRes{
            self.shouldPresent.append(SearchTextFieldItem(title: res.title))
        }
        print("We have finished with should present")
        return true
        
    }
    
    public func getLocationFromAddress(zipCode : String){
        let zipcode = 12345
        var lat = 0.0
        var lon = 0.0
        let urlString = "https://www.zipcodeapi.com/rest/\(geocode)/info.json/\(zipcode)/degree"
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data,
                      error == nil else {
                      print(error?.localizedDescription ?? "Response Error")
                      return }
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                lat = jsonResponse["lat"] as! Double
                lon = jsonResponse["lng"] as! Double
                self.doReturnCoord(lat: lat, long: lon)
            } catch let parsingError {
                print("Error", parsingError)
            }
            
        }
        task.resume()
    }
    fileprivate func doReturnCoord(lat: Double, long: Double){
        self.currentLoc = CLLocation(latitude: lat, longitude: long)
        
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
//        upload()
        dismiss(animated: true, completion: nil)
    }
//    func upload(){
//        AWSS3Manager.shared.uploadImage(image: self.preview.image!, completion:{ (uploadedFileUrl, error) in
//                if let finalPath = uploadedFileUrl as? String {
//                    self.imageURL = finalPath
//                } else {
//                    print("\(String(describing: error?.localizedDescription))")
//                }
//        })
//    }
    
}


struct SearchResult: Any{
    var title: String
    var id: String
}
