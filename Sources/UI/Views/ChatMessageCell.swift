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

import SwiftUI

struct ChatMessageCell: View {

    // MARK: - Properties

    @EnvironmentObject private var style: ChatStyle

    @State private var forceDateHeader = false

    private let message: ChatMessage
    private let messageGroupPosition: MessageGroupPosition
    private let onRichMessageElementTapped: (_ textToSend: String?, RichMessageSubElementType) -> Void

    private var isMultiAttachment: Bool {
        message.types.count > 1
    }

    // MARK: - Init

    init(
        message: ChatMessage,
        messageGroupPosition: MessageGroupPosition,
        onRichMessageElementTapped: @escaping (_ textToSend: String?, RichMessageSubElementType) -> Void
    ) {
        self.message = message
        self.messageGroupPosition = messageGroupPosition
        self.onRichMessageElementTapped = onRichMessageElementTapped
    }

    // MARK: - Builder

    var body: some View {
        VStack {
            if isMultiAttachment {
                MultipleAttachmentContainer(message)
            } else {
                messageContent
            }
        }
    }
}

// MARK: - Subviews

private extension ChatMessageCell {

    @ViewBuilder
    var messageContent: some View {
        ForEach(message.types, id: \.self) { type in
            switch type {
            case .text(let text):
                TextMessageCell(message: message, text: text, position: messageGroupPosition)
                    .onTapGesture {
                        withAnimation {
                            forceDateHeader.toggle()
                        }
                    }
            case .video(let item):
                VideoMessageCell(message: message, item: item, isMultiAttachment: message.types.count > 1 ? true : false)
            case .image(let item):
                ImageMessageCell(message: message, item: item, isMultiAttachment: message.types.count > 1 ? true : false)
            case .audio(let item):
                AudioMessageCell(message: message, item: item, isMultiAttachment: message.types.count > 1 ? true: false)
            case .linkPreview(let item):
                LinkPreviewCell(message: message, item: item) { url in
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }
            case .richContent(let content):
                switch content {
                case .gallery(let elements):
                    GalleryMessageCell(message: message, elements: elements, elementSelected: onRichMessageElementTapped)
                case .menu(let elements):
                    MenuMessageCell(message: message, elements: elements) { element in
                        onRichMessageElementTapped(nil, element)
                    }
                case .quickReplies(let item):
                    QuickRepliesMessageCell(message: message, item: item) { option in
                        onRichMessageElementTapped(option.title, .button(option))
                    }
                case .listPicker(let item):
                    ListPickerMessageCell(message: message, item: item) { option in
                        onRichMessageElementTapped(option.textToSend, option)
                    }
                case .richLink(let item):
                    RichLinkMessageCell(message: message, item: item) { url in
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }
                case .satisfactionSurvey(let item):
                    SatisfactionSurveyMessageCell(message: message, item: item) { url in
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }
                case .custom(let item):
                    CustomMessageCell(message: message, item: item) { url in
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Helpers

private extension RichMessageSubElementType {

    var textToSend: String {
        // Only interaction with button is enabled
        guard case .button(let entity) = self else {
            return ""
        }

        return entity.title
    }
}

// MARK: - Preview

struct DefaultMessageItemPreview: PreviewProvider {
    
    static let agentTextMessage = MockData.textMessage(user: MockData.agent)
    static let agentImageMessage = MockData.imageMessage(user: MockData.agent, elementsCount: 2)
    static let customerAudioMessage = MockData.audioMessage(user: MockData.customer)
    static let customerImageMessage = MockData.imageMessage(user: MockData.customer, elementsCount: 5)
    static let manager = ChatManager(messages: [customerAudioMessage, agentImageMessage, agentTextMessage, customerImageMessage])
    
    static var previews: some View {
        Group {
            LazyVStack {
                ChatMessageCell(message: agentImageMessage, messageGroupPosition: .first) { _, _ in }
                
                ChatMessageCell(message: agentTextMessage, messageGroupPosition: .inside) { _, _ in }

                ChatMessageCell(message: customerAudioMessage, messageGroupPosition: .first) { _, _ in }
                
                ChatMessageCell(message: customerImageMessage, messageGroupPosition: .last) { _, _ in }
            }
            .previewDisplayName("Light mode")
            
            LazyVStack {
                ChatMessageCell(message: agentImageMessage, messageGroupPosition: .first) { _, _ in }
                
                ChatMessageCell(message: agentTextMessage, messageGroupPosition: .inside) { _, _ in }

                ChatMessageCell(message: customerAudioMessage, messageGroupPosition: .first) { _, _ in }
                
                ChatMessageCell(message: customerImageMessage, messageGroupPosition: .last) { _, _ in }
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark mode")
        }
        .environmentObject(ChatStyle())
    }
}
