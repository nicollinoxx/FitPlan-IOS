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

        Hotwire.config.defaultViewController = { url in WebViewController(url: url) }
        Hotwire.config.makeCustomErrorView = { error, handler in LocalizedErrorView(error: error, handler: handler) }
#if DEBUG
        Hotwire.config.debugLoggingEnabled = true
#endif
    }
}
