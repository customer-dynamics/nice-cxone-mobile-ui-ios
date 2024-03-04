//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-ui-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import Foundation

extension Error {
    
    /// Logs localized description of the error with additional message, if it exists.
    func logError(_ additionalMessage: String? = nil, fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
        if let additionalMessage {
            LogManager.error("\(additionalMessage) error: \(self.localizedDescription)", fun: fun, file: file, line: line)
        } else {
            LogManager.error(self.localizedDescription, fun: fun, file: file, line: line)
        }
    }
}
