//
//  FiveLettersApp.swift
//  FiveLetters
//
//  Created by Peter Paul Blomert on 21.01.25.
//

import SwiftUI

@main
struct FiveLettersApp: App {
    @StateObject private var gameController = GameController.shared
    
    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            ContentViewiOS()
                .environmentObject(gameController)
            #else
            ContentViewMac()
                .environmentObject(gameController)
            #endif
        }
    }
}
