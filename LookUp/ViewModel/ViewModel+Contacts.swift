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
    
    func getContacts() {
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactBirthdayKey as CNKeyDescriptor,
        ]
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        
        var cnContacts = [CNContact]()
        
        DispatchQueue.global(qos: .default).async {
            do {
                try CNContactStore().enumerateContacts(with: request) { contact, _ in
                    cnContacts.append(contact)
                }
            } catch {
                print("Error: \(error)")
            }
            
            self.cnContacts = cnContacts
            
            let contactsDictionary = cnContacts.makeDictionary()
            self.contactsDictionary = contactsDictionary
            
//            print("contactsDictionary: \(contactsDictionary)")
        }
    }
}
