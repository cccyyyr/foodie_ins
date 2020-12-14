//
//  Feed.swift
//  foodie_ins
//
//  Created by Cathy Chen on 2020/12/3.
//

import UIKit
import Firebase
import Kingfisher
class FeedController: UITableViewController{
    let db = Firestore.firestore()
    var userId: String?
    var postList:[Post] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        fetchDb()
    }
    
    @objc func refresh(sender:AnyObject)
    {
        fetchDb()
        self.refreshControl?.endRefreshing()
    }
    
    
    private func fetchDb(){
        
       let docRef = self.db.collection("posts")
        docRef.getDocuments() { (querySnapshot, err) in
            self.postList = []
            if let err = err {
                self.postList = []
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let aPost = Post(userName: document.get("userName") as! String, caption: document.get("caption") as! String, pic: document.get("imageURL") as! String, location: document.get("location") as! String)
                    self.postList.append(aPost)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "blah", for: indexPath)
        let curr = postList[indexPath.row]
        if let name = cell.viewWithTag(1) as? UILabel {
            name.text = "Loading"
            if curr.userName != "Annoymous"{
                let docRef = db.collection("users").document("\(curr.userName)")
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        name.text = document.get("username") as? String
                    } else {
                        print("can't find document \(curr.userName)")
                    }
                }
            }else{
                name.text = "Annoymous"
            }
        }
        if let cap = cell.viewWithTag(4) as? UILabel {
            cap.text = curr.caption
        }
        if let pic = cell.viewWithTag(3) as? UIImageView {
            pic.kf.setImage(with: URL(string: curr.pic))
        }
        if let loca = cell.viewWithTag(2) as? UILabel {
            loca.text = curr.location
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 600
    }
    
    
    // MARK: - Handle user interaction

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toDetail"{
//            guard let DVC = segue.destination as? DetailViewController,
//                let index = tableView.indexPathForSelectedRow?.row
//                else {
//                    return
//            }
//            DVC.contact = contactList[index]
//        } else if segue.identifier == "toAdd"{
//            guard let AVC = segue.destination as? UINavigationController,
//                  let ACVC = AVC.topViewController as?
//                    AddContactViewController
//                else{
//                    return
//            }
//            ACVC.delegate = self
//        }
           
        }
}

