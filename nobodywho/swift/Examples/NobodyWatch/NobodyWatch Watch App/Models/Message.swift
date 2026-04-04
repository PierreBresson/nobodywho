//
//  Message.swift
//  NobodyWatch Watch App
//
//  Created by pierre on 20/03/2026.
//

import Foundation

struct Message: Identifiable {
    let id = UUID()
    let role: Role
    let content: String

    enum Role {
        case user, assistant
    }
}
