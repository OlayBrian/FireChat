//
//  MessageManager.swift
//  FireChat
//
//  Created by Brian Ribeiro on 11/24/26.
//

import Foundation
import FirebaseFirestore

@Observable // <-- Add the Observable macro
class MessageManager {
    
    var messages: [Message] = []
    
    init(isMocked: Bool = false) {
        if isMocked {
            messages = Message.mockedMessages
        } else {
            // TODO: Fetch messages from Firestore database
            
        }
    }
    
    // TODO: Save message
    
    // TODO: Get messages
}
