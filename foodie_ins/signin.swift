//
//  signin.swift
//  foodie_ins
//
//  Created by Cathy Chen on 2020/12/4.
//

import Foundation
import UIKit
import Firebase
class SignInViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var pw: UITextField!
    @IBAction func login(_ sender: Any) {
        if email.hasText && pw.hasText{
            Auth.auth().signIn(withEmail: email.text!, password: pw.text!) { [weak self] authResult, error in
                guard self != nil else { return }
                  }
        }
    }
}
