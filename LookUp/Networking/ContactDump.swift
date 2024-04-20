//
//  ContactDump.swift
//  LookUp
//  
//  Created by Andrew Zheng (github.com/aheze) on 4/19/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import Foundation

struct ContactDump: Codable {
    // my self
    var ownPhoneNumber: String
    var ownName: String
    
    // everyone else
    // phone Number: ContactMetadata
    var contactsDictionary: [String : ContactMetadata]
}
