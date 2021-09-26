//
//  File.swift
//  File
//
//  Created by Enoxus on 19.09.2021.
//

import AppKit

class WindowDelegate: NSObject, NSWindowDelegate {

    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(0)
    }
}
