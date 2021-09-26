//
//  File.swift
//  File
//
//  Created by Enoxus on 18.09.2021.
//

import AppKit
import SwiftUI

@main class Client {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
}
