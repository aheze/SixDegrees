//
//  ViewModel.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/19/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import Combine
import Contacts
import SwiftUI

class ViewModel: ObservableObject {
    @Published var authorizationStatus = CNAuthorizationStatus.notDetermined
    
    @Published var cnContacts = [CNContact]()
    @Published var contactsDictionary = [String: ContactMetadata]()
    
    @Published var showingStartup = false
    @Published var finishedOnboarding = false
    
    @Published var phoneNumber = ""
    @Published var name = ""
    @Published var bio = ""
    @Published var email = ""
    @Published var instagram = ""
    
    var cancellables = Set<AnyCancellable>()
    
    @Published var isConnecting = false
    
    @Published var connectedPath: [String]?
    
    init() {
        DispatchQueue.main.async {
            self.authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        }
        
//        let graph = DummyData.generateGraph(phoneNumber: Strin, targetDepth: <#T##Int#>: ownContactMetadata, targetDepth: 3)
//        print("graph: \(graph)")
    }
}
