//
//  ViewModel+Upload.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/19/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import Foundation

extension ViewModel {
    func upload() {
        Task {
            try await Networking.uploadContactsDictionary(
                ownPhoneNumber: ownPhoneNumber,
                ownName: ownName,
                contactsDictionary: contactsDictionary
            )
        }
    }
}
