import HotwireNative
import SwiftUI
import WebKit

// Hotwire Native ships the texts below in English only. These copies read them
// from the app's string catalog instead.

/// The alert and confirmation dialogs web pages open, e.g. with turbo-confirm.
final class LocalizedUIController: WKUIController {
    private weak var presenter: WKUIControllerDelegate?

    override init(delegate: WKUIControllerDelegate!) {
        presenter = delegate
        super.init(delegate: delegate)
    }

    override func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "Close", bundle: AppLanguage.bundle), style: .default) { _ in completionHandler() })
        present(alert, otherwise: completionHandler)
    }

    override func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "OK", bundle: AppLanguage.bundle), style: .default) { _ in completionHandler(true) })
        alert.addAction(UIAlertAction(title: String(localized: "Cancel", bundle: AppLanguage.bundle), style: .cancel) { _ in completionHandler(false) })
        present(alert) { completionHandler(false) }
    }

    private func present(_ alert: UIAlertController, otherwise fallback: () -> Void) {
        guard let presenter else { return fallback() }
        presenter.present(alert, animated: true)
    }
}

/// The screen shown when a page fails to load.
struct LocalizedErrorView: ErrorPresentableView {
    let error: HotwireNativeError
    let handler: ErrorPresenter.Handler?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 38, weight: .semibold))
                .foregroundColor(.accentColor)

            Text("Error loading page", bundle: AppLanguage.bundle)
                .font(.largeTitle)

            Text(error.localizedDescription)
                .font(.body)
                .multilineTextAlignment(.center)

            if let handler {
                Button(action: handler) { Text("Retry", bundle: AppLanguage.bundle) }
                    .font(.system(size: 17, weight: .bold))
            }
        }
        .padding(32)
    }
}
