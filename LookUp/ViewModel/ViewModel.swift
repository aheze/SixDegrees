//
//  ViewModel.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/19/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import Contacts
import SwiftUI

class ViewModel: ObservableObject {
    @Published var authorizationStatus = CNAuthorizationStatus.notDetermined
    
    @Published var ownPhoneNumber = "9252149133"
    @Published var ownName = "Andrew Zheng"
    
    var ownContactMetadata: ContactMetadata {
        ContactMetadata(phoneNumber: ownPhoneNumber, name: ownName)
    }
    
    @Published var cnContacts = [CNContact]()
    @Published var contactsDictionary = [String: ContactMetadata]()
    
    init() {
        DispatchQueue.main.async {
            self.authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        }
        
//        let graph = DummyData.generateGraph(phoneNumber: Strin, targetDepth: <#T##Int#>: ownContactMetadata, targetDepth: 3)
//        print("graph: \(graph)")
    }
}
