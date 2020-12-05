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
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var pw: UITextField!
    func createUser(email: String, password: String){
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    // [START_EXCLUDE]
            guard let user = authResult?.user, error == nil else {
                print("Im here")
                print(error.debugDescription)
                        return
            }
            self.userId = user.uid
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard self != nil else { return }
                    
                  }
        }
    }
    @IBAction func signUp(_ sender: Any) {
        if email.hasText && pw.hasText{
            createUser(email: email.text!, password: pw.text!)
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

