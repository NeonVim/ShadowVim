//
//  Copyright © 2023 Mickaël Menu
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import AppKit
import Foundation

struct Alert {
    enum Style {
        case info
        case warning
    }

    enum Accessory {
        case code(String)
    }

    var style: Style
    var title: String
    var message: String?

    init(style: Style, title: String, message: String? = nil) {
        self.style = style
        self.title = title
        self.message = message
    }

    init(error: Error) {
        style = .warning

        if let error = error as? LocalizedError {
            title = error.errorDescription ?? ""
            message = error.failureReason ?? ""
        } else {
            title = "An error occurred"
            accessory = .code(String(reflecting: error))
        }
    }

    var accessory: Accessory?

    private typealias Button = (title: String, action: () -> Void)
    private var buttons: [Button] = []

    mutating func addButton(_ title: String, action: @escaping () -> Void) {
        precondition(buttons.count < 3)
        buttons.append((title: title, action: action))
    }

    func showModal() {
        let response = alert().runModal()
        switch response {
        case .alertFirstButtonReturn:
            buttons[0].action()
        case .alertSecondButtonReturn:
            buttons[0].action()
        case .alertThirdButtonReturn:
            buttons[0].action()
        default:
            return
        }
    }

    private func alert() -> NSAlert {
        let alert = NSAlert()
        switch style {
        case .info:
            alert.alertStyle = .informational
        case .warning:
            alert.alertStyle = .warning
        }

        alert.messageText = title
        alert.informativeText = message ?? ""

        switch accessory {
        case let .code(code):
            let codeView = NSTextView(frame: .init(origin: .zero, size: .init(width: 350, height: 0)))
            codeView.string = code
            codeView.font = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
            codeView.sizeToFit()
            codeView.isEditable = false
            codeView.isSelectable = true
            alert.accessoryView = codeView
        case .none:
            break
        }

        for (title, _) in buttons {
            alert.addButton(withTitle: title)
        }

        return alert
    }
}