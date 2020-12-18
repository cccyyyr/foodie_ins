//
//  PostStruct.swift
//  foodie_ins
//
//  Created by Cathy Chen on 2020/12/3.
//

import Foundation
import UIKit
import Firebase
struct Post: Codable{
    var userName: String
    var caption: String
    var pic: String
    var location: String
}

