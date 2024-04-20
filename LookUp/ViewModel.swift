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
    
    init() {
        authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
    }
    
}
