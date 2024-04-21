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

        dictionary["6692719036"] = ContactMetadata(
            phoneNumber: "6692719036",
            name: "Brayden Tam",
            email: "brayden.tam@gmail.com",
            birthdayMonth: 11,
            birthdayDay: 2,
            birthdayYear: 2005
        )

        dictionary["9254485457"] = ContactMetadata(
            phoneNumber: "9254485457",
            name: "Neel Redkar",
            email: "neelr@ucla.edu",
            birthdayMonth: 3,
            birthdayDay: 2,
            birthdayYear: 2005
        )

        dictionary["123456789"] = ContactMetadata(
            phoneNumber: "123456789",
            name: "Arjun Khemani",
            email: "arjun@getairchat.com",
            birthdayMonth: 2,
            birthdayDay: 1,
            birthdayYear: 2006
        )

        dictionary["4087262484"] = ContactMetadata(
            phoneNumber: "4087262484",
            name: "Divik Chotani",
            email: nil,
            birthdayMonth: 3,
            birthdayDay: 32,
            birthdayYear: 2005
        )

        dictionary["3102513864"] = ContactMetadata(
            phoneNumber: "3102513864",
            name: "Lynn Tanisaka",
            email: "lynn64904@gmail.com",
            birthdayMonth: 6,
            birthdayDay: 9,
            birthdayYear: 2005
        )

        dictionary["6198871189"] = ContactMetadata(
            phoneNumber: "6198871189",
            name: "Kiley Phung",
            email: nil,
            birthdayMonth: 11,
            birthdayDay: 26,
            birthdayYear: 2005
        )

        dictionary["6282079012"] = ContactMetadata(
            phoneNumber: "6282079012",
            name: "Sigil Wen",
            email: "sigil.w3n@gmail.com",
            birthdayMonth: nil,
            birthdayDay: nil,
            birthdayYear: nil
        )

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
            if phoneNumber.hasPrefix("+1") {
                phoneNumber = String(phoneNumber.dropFirst(2))
            } else {
                return nil
            }
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
