//
//  signup.swift
//  foodie_ins
//
//  Created by Cathy Chen on 2020/12/4.
//

import Foundation
import UIKit

import AWSS3
import AWSCore
import Firebase

class SignUpViewController: UIViewController {
    var userId: String?
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var pw: UITextField!
    func createUser(email: String, password: String, username: String){
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    // [START_EXCLUDE]
            guard let user = authResult?.user, error == nil else {
                print(error.debugDescription)
                        return
            }
            self.userId = user.uid
            let db = Firestore.firestore()
            db.collection("users").document("\(user.uid)").setData(["username": username, "posts": []]) { (error) in
                if error != nil {
                    print("Error saving user data")
                }
            }
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard self != nil else { return }
                    
                  }
            
        }
    }
    @IBAction func signUp(_ sender: Any) {
        if email.hasText && pw.hasText && userName.hasText{
            createUser(email: email.text!, password: pw.text!, username: userName.text!)

        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signup"{
            guard segue.destination is UITableViewController
                else {
                    return
            }
            
        }
    }
}

