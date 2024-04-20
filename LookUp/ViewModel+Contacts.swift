//
//  ViewModel+Contacts.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/19/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import Contacts
import SwiftUI

extension ViewModel {
    func requestAccess(successfullyFinished: (() -> Void)?) {
        CNContactStore().requestAccess(for: .contacts) { [weak self] success, _ in
            guard let self else { return }
            
            DispatchQueue.main.async {
                if success {
                    self.authorizationStatus = .authorized
                    successfullyFinished?()
                } else {
                    self.authorizationStatus = .denied
                }
            }
        }
    }
    
    func getContacts() {}
}
