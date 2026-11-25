//
//  ChatView.swift
//  FireChat
//
//  Created by Brian Ribeiro on 11/24/26.
//

import SwiftUI

struct ChatView: View {
    @Environment(AuthManager.self) private var authManager

    @State private var messageManager: MessageManager
    @State private var isShowingClearConfirmation = false
    @State private var clearHistoryError = ""
    @State private var isShowingClearError = false

    init(isMocked: Bool = false) {
        messageManager = MessageManager(isMocked: isMocked)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(messageManager.messages) { message in
                        MessageRow(
                            text: message.text,
                            timestamp: message.timestamp,
                            isOutgoing: authManager.userEmail == message.username
                        )
                    }
                }
                .padding(.vertical, 8)
            }
            .defaultScrollAnchor(.bottom)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                SendMessageView { messageText in
                    messageManager.sendMessage(
                        text: messageText,
                        username: authManager.userEmail ?? ""
                    )
                }
            }
            .navigationTitle("FireChat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 0) {
                        Text("FireChat")
                            .font(.headline)

                        if let email = authManager.userEmail {
                            Text(email)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Clear Chat", systemImage: "trash", role: .destructive) {
                            isShowingClearConfirmation = true
                        }

                        Button("Sign Out", systemImage: "rectangle.portrait.and.arrow.right") {
                            authManager.signOut()
                        }
                    } label: {
                        Label("Chat Options", systemImage: "ellipsis.circle")
                    }
                }
            }
        }
        .confirmationDialog(
            "Clear chat history?",
            isPresented: $isShowingClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear All Messages", role: .destructive) {
                Task {
                    do {
                        try await messageManager.clearHistory()
                    } catch {
                        clearHistoryError = error.localizedDescription
                        isShowingClearError = true
                    }
                }
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently deletes every message for everyone.")
        }
        .alert("Couldn’t Clear Chat", isPresented: $isShowingClearError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(clearHistoryError)
        }
    }
}

struct SendMessageView: View {
    var onSend: (String) -> Void

    @State private var messageText = ""

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            TextField("Message", text: $messageText, axis: .vertical)
                .padding(.leading)
                .padding(.trailing, 4)
                .padding(.vertical, 8)

            Button {
                onSend(messageText)
                messageText = ""
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .bold()
                    .padding(4)
            }
            .disabled(messageText.isEmpty)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 19)
                .stroke(Color(uiColor: .systemGray2))
        )
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.thickMaterial)
    }
}

struct MessageRow: View {
    let text: String
    let timestamp: Date
    let isOutgoing: Bool

    var body: some View {
        HStack {
            if isOutgoing {
                Spacer()
            }

            VStack(alignment: isOutgoing ? .trailing : .leading, spacing: 3) {
                Text(text)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(isOutgoing ? .white : .primary)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                isOutgoing
                                    ? Color.blue.gradient
                                    : Color(.systemGray5).gradient
                            )
                    )

                Text(
                    timestamp,
                    format: .dateTime
                        .month(.abbreviated)
                        .day()
                        .hour()
                        .minute()
                )
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
            }
            .containerRelativeFrame(
                .horizontal,
                count: 7,
                span: 5,
                spacing: 0,
                alignment: isOutgoing ? .trailing : .leading
            )

            if !isOutgoing {
                Spacer()
            }
        }
    }
}

#Preview {
    ChatView(isMocked: true)
        .environment(AuthManager(isMocked: true))
}
