import SwiftUI

/* the history view page */
struct HistoryView: View {

    let records: [LoveRecord]
    @Environment(\.dismiss) var dismiss

    /* automatic scroll to the bottom of the page when entering */
    var body: some View {
        VStack {
            ScrollViewReader{ proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(records, id: \.id) { record in
                            MessageRow(record: record)
                                .id(record.id)
                        }
                    }
                    .padding()
                }
                .onAppear{
                    scrollToBottom(proxy)
                }
                .onChange(of: records.count) { _, _ in
                    scrollToBottom(proxy)
                }

                Spacer()
            }
            
        }
        .navigationTitle("历史记录")
        .navigationBarTitleDisplayMode(.inline)
    }
        
    
    private func scrollToBottom(_ proxy: ScrollViewProxy){
        guard let lastId = records.last?.id else { return }
        
        DispatchQueue.main.async{
            proxy.scrollTo(lastId, anchor: .bottom)
        }
    }
}

struct MessageRow: View {

    let record: LoveRecord

    var isMe: Bool {
        record.sender == .me
    }

    var body: some View {
        HStack {

            if isMe {
                messageBubble
                Spacer()
            } else {
                Spacer()
                messageBubble
            }
        }
    }

    var messageBubble: some View {
        VStack(alignment: .leading, spacing: 4) {

            Text("❤️ 想你了")
                .font(.headline)

            Text(formatDate(record.date) + " · " + record.placeName)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(12)
        .background(isMe ? Color.pink : Color.purple.opacity(0.7))
        .cornerRadius(14)
        .foregroundColor(.white)
        .frame(maxWidth: 260, alignment: isMe ? .leading : .trailing)
    }
}

func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    return formatter.string(from: date)
}
