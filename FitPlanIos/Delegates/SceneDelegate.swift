import HotwireNative
import UIKit

final class SceneDelegate: UIResponder {
    var window: UIWindow?

    private lazy var tabBarController = TabBarController(navigatorDelegate: self, lazyLoadTabs: true)

    private func promptForAuthentication() {
        // Clean up empty screen from 401 response.
        tabBarController.activeNavigator.pop(animated: false)
        tabBarController.activeNavigator.route(FitPlan.signInURL)
    }

    private func noticeMessage(from url: URL) -> String? {
        URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "notice" })?.value
    }
}

extension SceneDelegate: UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        tabBarController.load(HotwireTab.all)
    }
}

extension SceneDelegate: NavigatorDelegate {
    func handle(proposal: VisitProposal, from navigator: Navigator) -> ProposalResult {
        // A link to another tab's start page selects that tab instead of opening
        // the page inside this one, so the tab bar never highlights the wrong tab.
        if tabBarController.selectTab(for: proposal.url, from: navigator) {
            return .reject
        }

        // Display notice messages natively
        if let message = noticeMessage(from: proposal.url) {
            tabBarController.presentToast(message.replacingOccurrences(of: "+", with: " "))
        }

        switch proposal.viewController {
        case NumbersViewController.pathConfigurationIdentifier:
            return .acceptCustom(NumbersViewController(title: "Numbers"))
        default:
            return .accept
        }
    }

    func visitableDidFailRequest(_ visitable: any Visitable, error: HotwireNativeError, retryHandler: RetryBlock?) {
        switch error {
        case .http(.client(.unauthorized)):
            promptForAuthentication()
        default:
            if let errorPresenter = visitable as? ErrorPresenter {
                errorPresenter.presentError(error, retryHandler: retryHandler)
            }
        }
    }
}
