import HotwireNative
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureAppearance()
        configureHotwire()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // Opaque navigation and tab bars, so screens are laid out between them
    // instead of underneath: a translucent bar let a freshly pushed page paint
    // behind the navigation bar until the first scroll.
    private func configureAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().isTranslucent = false

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().isTranslucent = false
    }

    private func configureHotwire() {
        Hotwire.loadPathConfiguration(from: [
            .file(Bundle.main.url(forResource: "path-configuration", withExtension: "json")!)
        ])
        // Rules match the path alone, so /sign_in?email_hint=... is still the modal
        // sign in page and /sheets?type=diet still the sheets start page.
        Hotwire.config.pathConfiguration.matchQueryStrings = false

        Hotwire.registerBridgeComponents(BridgeComponent.allTypes)

        // Registering replaces the defaults, so they follow the app's own handler.
        Hotwire.registerRouteDecisionHandlers([
            SocialSignInRouteDecisionHandler(),
            AppNavigationRouteDecisionHandler(),
            SafariViewControllerRouteDecisionHandler(),
            SystemNavigationRouteDecisionHandler()
        ])

        Hotwire.config.defaultViewController = { url in WebViewController(url: url) }
        Hotwire.config.makeCustomErrorView = { error, handler in LocalizedErrorView(error: error, handler: handler) }
#if DEBUG
        Hotwire.config.debugLoggingEnabled = true
#endif
    }
}

/// Google refuses to sign anyone in from a web view, so FitPlan's own /auth/ pages,
/// which start the Google and Facebook flows, open in a Safari view controller the
/// way another site would. The Rails app hands the session back to the web view
/// afterwards (see SessionHandoff there).
final class SocialSignInRouteDecisionHandler: RouteDecisionHandler {
    let name = "social-sign-in"

    private let safari = SafariViewControllerRouteDecisionHandler()

    func matches(proposal: VisitProposal, configuration: Navigator.Configuration) -> Bool {
        proposal.url.path.hasPrefix("/auth/")
    }

    func handle(proposal: VisitProposal, configuration: Navigator.Configuration, navigator: Navigating) -> Router.Decision {
        safari.handle(proposal: proposal, configuration: configuration, navigator: navigator)
    }
}
