import SwiftUI
import SwiftData

struct AIChatView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = AIChatViewModel()
    @State private var inputText: String = ""
    @State private var showClearAlert = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            ChatMessageRowView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) {
                    scrollToBottom(proxy)
                }
                .onAppear {
                    viewModel.configureIfNeeded(context: context)
                    scrollToBottom(proxy)
                }
            }

            ChatInputBarView(text: $inputText, onSend: sendMessage)
        }
        .navigationTitle("ai_chat_title")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    showClearAlert = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .alert("clear_chat_history_title", isPresented: $showClearAlert) {
            Button("clear_button", role: .destructive) { viewModel.clearHistory() }
            Button("cancel_button", role: .cancel) {}
        } message: {
            Text("clear_chat_history_message")
        }
    }

    private func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        inputText = ""
        viewModel.send(text: trimmed)
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        guard let last = viewModel.messages.last else { return }
        withAnimation(.easeOut(duration: 0.2)) {
            proxy.scrollTo(last.id, anchor: .bottom)
        }
    }
}
