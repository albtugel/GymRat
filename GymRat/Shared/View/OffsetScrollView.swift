import SwiftUI
import UIKit

struct OffsetScrollView<Content: View>: UIViewRepresentable {
    @Binding var contentOffset: CGPoint
    let showsIndicators: Bool
    let content: Content

    init(contentOffset: Binding<CGPoint>, showsIndicators: Bool = true, @ViewBuilder content: () -> Content) {
        self._contentOffset = contentOffset
        self.showsIndicators = showsIndicators
        self.content = content()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(contentOffset: $contentOffset)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = showsIndicators
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.delegate = context.coordinator

        let hosting = UIHostingController(rootView: AnyView(content))
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        hosting.view.backgroundColor = .clear

        scrollView.addSubview(hosting.view)
        context.coordinator.hosting = hosting

        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            hosting.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        context.coordinator.hosting?.rootView = AnyView(content)

        let current = scrollView.contentOffset
        if abs(current.y - contentOffset.y) > 1 || abs(current.x - contentOffset.x) > 1 {
            context.coordinator.isProgrammaticScroll = true
            scrollView.setContentOffset(contentOffset, animated: false)
            context.coordinator.isProgrammaticScroll = false
        }
    }

    final class Coordinator: NSObject, UIScrollViewDelegate {
        var hosting: UIHostingController<AnyView>?
        private var contentOffset: Binding<CGPoint>
        var isProgrammaticScroll = false

        init(contentOffset: Binding<CGPoint>) {
            self.contentOffset = contentOffset
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard !isProgrammaticScroll else { return }
            contentOffset.wrappedValue = scrollView.contentOffset
        }
    }
}
