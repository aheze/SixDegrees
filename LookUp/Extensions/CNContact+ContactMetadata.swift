//
//  CNContact+ContactMetadata.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/19/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import Contacts

extension Array where Element == CNContact {
    func createContactMetadatas() -> [ContactMetadata] {
        return compactMap { $0.createContactMetadata() }
    }

    func makeDictionary() -> [String: ContactMetadata] {
        var dictionary = [String: ContactMetadata]()

        for contact in self {
            if let metadata = contact.createContactMetadata() {
                dictionary[metadata.phoneNumber] = metadata
            }
        }

        return dictionary
    }
}

extension CNContact {
    func createContactMetadata() -> ContactMetadata? {
        guard let phoneNumberRaw = phoneNumbers.first else { return nil }
        let original = phoneNumberRaw.value.stringValue
        var phoneNumber = phoneNumberRaw.value.stringValue

        let characterSet = CharacterSet(charactersIn: "+0123456789")

        phoneNumber = String(phoneNumber.unicodeScalars.filter { characterSet.contains($0) })

        if phoneNumber.hasPrefix("+") {
            let components = phoneNumber.components(separatedBy: " ")
            guard components.count >= 2 else {
                return nil
            }

            phoneNumber = components.dropLast().joined(separator: "")
        }

        let name: String? = {
            var string = ""

            string.append(givenName)
            string.append(" ")
            string.append(familyName)

            string = string.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !string.isEmpty {
                return string
            } else {
                return nil
            }
        }()

        let contact = ContactMetadata(
            phoneNumber: phoneNumber,
            name: name,
            email: emailAddresses.first.map { String($0.value) },
            birthdayMonth: birthday?.month,
            birthdayDay: birthday?.day,
            birthdayYear: birthday?.year
        )

        return contact
    }
}
