import SwiftUI
import UIKit

final class KeyboardObserver: ObservableObject {
    @Published var height: CGFloat = 0

    private var willShowObserver: NSObjectProtocol?
    private var willHideObserver: NSObjectProtocol?

    init() {
        willShowObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self else { return }
            guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            withAnimation(.easeOut(duration: 0.2)) {
                self.height = frame.height
            }
        }

        willHideObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            withAnimation(.easeOut(duration: 0.2)) {
                self?.height = 0
            }
        }
    }

    deinit {
        if let willShowObserver {
            NotificationCenter.default.removeObserver(willShowObserver)
        }
        if let willHideObserver {
            NotificationCenter.default.removeObserver(willHideObserver)
        }
    }
}
