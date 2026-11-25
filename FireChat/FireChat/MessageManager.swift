//
//  MessageManager.swift
//  FireChat
//
//  Created by Brian Ribeiro on 11/24/26.
//

import Foundation
import FirebaseFirestore

@Observable
class MessageManager {
    var messages: [Message] = []

    private let dataBase = Firestore.firestore()
    private let isMocked: Bool

    init(isMocked: Bool = false) {
        self.isMocked = isMocked

        if isMocked {
            messages = Message.mockedMessages
        } else {
            getMessages()
        }
    }

    func getMessages() {
        dataBase.collection("messages").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }

            let messages = documents.compactMap { document in
                do {
                    return try document.data(as: Message.self)
                } catch {
                    print("Error decoding document into message: \(error)")
                    return nil
                }
            }

            self.messages = messages.sorted { $0.timestamp < $1.timestamp }
        }
    }

    func sendMessage(text: String, username: String) {
        do {
            let message = Message(
                id: UUID().uuidString,
                text: text,
                timestamp: Date(),
                username: username
            )

            try dataBase.collection("messages").document().setData(from: message)
        } catch {
            print("Error sending message to Firestore: \(error)")
        }
    }

    func clearHistory() async throws {
        if isMocked {
            messages.removeAll()
            return
        }

        while true {
            let snapshot = try await dataBase.collection("messages")
                .limit(to: 500)
                .getDocuments()

            guard !snapshot.documents.isEmpty else {
                return
            }

            let batch = dataBase.batch()

            for document in snapshot.documents {
                batch.deleteDocument(document.reference)
            }

            try await batch.commit()
        }
    }
}
