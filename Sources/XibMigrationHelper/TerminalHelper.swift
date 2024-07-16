//
//  File.swift
//  
//
//  Created by Martin Freiwald on 15.07.24.
//

import Foundation
import ANSITerminal

struct TerminalHelper {
    static func clear() {
        clearScreen()
    }

    static func waitAndContinue() {
       // TOOD: Wait for keyboard input to continue...
        
        while true {
            if keyPressed() {
                // 4
                let char = readChar()
                if char == NonPrintableChar.enter.char() || char == NonPrintableChar.space.char() {
                    break
                }
            }
        }
    }

    static func inlinePrint(_ text: String) {
        write(text)
    }

    static func readSTDIN () -> String? {
        var input: String?

        while let line = readLine() {
            if input == nil {
                input = line
            } else {
                input! += "\n" + line
            }
        }

        return input
    }
}
