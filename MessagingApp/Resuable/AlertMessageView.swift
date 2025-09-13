import SwiftUI

struct AlertMessageView: View {
    @EnvironmentObject var alertMessageViewModel: AlertMessageViewModel
    @State private var height: CGFloat = 0
    @State private var backgroundColor: Color = .clear
    
    static let maxHeight: CGFloat = 150
    private let dismissAfter: TimeInterval = 3
    
    @State private var dismissTask: Task<Void, Never>?
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height < 0 {
                    height = max(0, AlertMessageView.maxHeight + value.translation.height)
                }
            }
            .onEnded { value in
                if value.translation.height > 0 {
                    height = AlertMessageView.maxHeight
                } else {
                    dismiss()
                }
            }
    }
    
    var body: some View {
        if let alert = alertMessageViewModel.alertMessage {
            RoundedRectangle(cornerRadius: 20)
                .fill(backgroundColor)
                .frame(height: height)
                .gesture(dragGesture)
                .animation(.spring(duration: 0.5), value: height)
                .overlay {
                    Text(alert.message)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .bold()
                        .padding(.horizontal)
                        .padding(.top)
                }
                .onAppear {
                    height = AlertMessageView.maxHeight
                    backgroundColor = alert.type.color
                    scheduleDismissal()
                }
                .onChange(of: alertMessageViewModel.showAlert) { _, showAlert in
                    if showAlert {
                        height = AlertMessageView.maxHeight
                        backgroundColor = alertMessageViewModel.alertMessage?.type.color ?? .clear
                        scheduleDismissal()
                    }
                }
                .ignoresSafeArea()
        }
    }
    
    private func scheduleDismissal() {
        dismissTask?.cancel()
        dismissTask = Task {
            do {
                try await Task.sleep(for: .seconds(dismissAfter))
                dismiss()
            } catch {
                // Task was cancelled.
            }
        }
    }
    
    private func dismiss() {
        withAnimation {
            height = 0
            backgroundColor = .clear
            alertMessageViewModel.dismissAlert()
        }
    }
}

extension AlertType {
    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .warning: return .orange
        case .info: return .blue
        }
    }
}
