import HotwireNative
import UIKit
import WebKit

extension HotwireTab {
    // Built on every use so the titles follow AppLanguage.
    static var all: [HotwireTab] {[
        HotwireTab(id: "sheets",    title: String(localized: "Sheets", bundle: AppLanguage.bundle),    image: UIImage(systemName: "list.bullet.clipboard"), url: FitPlan.sheetsURL),
        HotwireTab(id: "shares",    title: String(localized: "Shares", bundle: AppLanguage.bundle),    image: UIImage(systemName: "square.and.arrow.up"),   url: FitPlan.sharesURL),
        HotwireTab(id: "dashboard", title: String(localized: "Dashboard", bundle: AppLanguage.bundle), image: UIImage(systemName: "chart.bar"),             url: FitPlan.dashboardURL),
        HotwireTab(id: "social",    title: String(localized: "Social", bundle: AppLanguage.bundle),    image: UIImage(systemName: "person.2"),              url: FitPlan.socialURL),
        HotwireTab(id: "profile",   title: String(localized: "Profile", bundle: AppLanguage.bundle),   image: UIImage(systemName: "person.crop.circle"),    url: FitPlan.profileURL)
    ]}
}

/// Root of the app. Hotwire Native gives every tab its own `Navigator`, with
/// its own web views and navigation stack; this adds the behavior the Android
/// app has on top of that.
final class TabBarController: HotwireTabBarController {

    // What each tab last rendered under, used to detect a sign in, a sign out
    // or a change of language.
    private var renderedPages: [HotwireTab.ID: RenderedPage] = [:]

    private struct RenderedPage: Equatable {
        let sessionToken: String?
        let locale: String?
    }

    /// Selects the tab whose start page is `url`, when the visit comes from the
    /// tab on screen. Returns whether a tab was selected.
    func selectTab(for url: URL, from navigator: Navigator) -> Bool {
        guard navigator === activeNavigator,
              let target = HotwireTab.all.firstIndex(where: { isStartPage(url, of: $0) }),
              let current = currentTab, target != HotwireTab.all.firstIndex(of: current) else { return false }

        navigator.rootViewController.dismiss(animated: true)
        resetIfOutOfDate(HotwireTab.all[target])

        if #available(iOS 18.0, *) {
            selectedTab = tabs[target]
        } else {
            selectedIndex = target
        }

        activeNavigator.start()
        return true
    }

    /// Records what a tab's page rendered under. Called by every page on the
    /// tabs' main stacks, so the record always matches what the tab is showing
    /// -- even when signing in from one tab switches to another.
    func pageDidRender(in navigationController: UINavigationController) {
        guard let tab = HotwireTab.all.first(where: { navigator(for: $0)?.rootViewController === navigationController }) else { return }
        currentPage { [weak self] page in
            self?.renderedPages[tab.id] = page
            self?.followLanguage(of: page)
        }
    }

    /// Puts the tab titles in the language picked before the app was last closed.
    func followAppLanguage() {
        currentPage { [weak self] in self?.followLanguage(of: $0) }
    }

    // MARK: - Private

    private var currentTab: HotwireTab? {
        HotwireTab.all.first { navigator(for: $0) === activeNavigator }
    }

    private func isStartPage(_ url: URL, of tab: HotwireTab) -> Bool {
        // Rails links some pages with an explicit .html format (/sheets.html).
        let url = url.pathExtension == "html" ? url.deletingPathExtension() : url

        // The Rails root renders the sheets index, so it belongs to the first tab.
        let path = ["", "/"].contains(url.path) ? FitPlan.sheetsURL.path : url.path
        return url.host == tab.url.host && path == tab.url.path
    }

    /// Returns whether UIKit should go on selecting `tab`.
    private func shouldSelect(_ tab: HotwireTab) -> Bool {
        // Tapping the tab you are already on sends it back to its start page.
        guard tab != currentTab else {
            reset(tab)
            return false
        }

        resetIfOutOfDate(tab)
        return true
    }

    /// Each tab keeps whatever page it landed on, so signing in or out, or
    /// picking another language, leaves the other tabs on the previous one.
    /// Comparing the cookies the tab rendered under against the current ones
    /// detects exactly that, and only then is the tab sent back to its start
    /// page -- so tabs otherwise keep their history.
    private func resetIfOutOfDate(_ tab: HotwireTab) {
        currentPage { [weak self] page in
            guard let self, let rendered = renderedPages[tab.id], rendered != page else { return }
            reset(tab)
        }
    }

    /// Sends a tab back to its start page. When the start page is already at the
    /// root, pop back to it and refresh it; otherwise (e.g. the tab landed on
    /// /welcome) replace the root with the start page.
    private func reset(_ tab: HotwireTab) {
        guard let navigator = navigator(for: tab),
              let root = navigator.rootViewController.viewControllers.first else { return }

        if let root = root as? VisitableViewController, isStartPage(root.currentVisitableURL, of: tab) {
            navigator.clearAll(animated: true)
        } else {
            navigator.route(tab.url)
        }
    }

    /// The tab titles are the app's own, so they would otherwise stay in the
    /// device's language when another one is picked on the web.
    private func followLanguage(of page: RenderedPage) {
        AppLanguage.use(page.locale)

        for tab in HotwireTab.all {
            if #available(iOS 18.0, *) {
                tabs.first { $0.identifier == tab.id }?.title = tab.title
            } else {
                navigator(for: tab)?.rootViewController.tabBarItem.title = tab.title
            }
        }
    }

    private func currentPage(_ completion: @escaping (RenderedPage) -> Void) {
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            let value = { (name: String) -> String? in cookies.first { $0.name == name }?.value }
            completion(RenderedPage(sessionToken: value(FitPlan.sessionCookie), locale: value(FitPlan.localeCookie)))
        }
    }
}

extension TabBarController {
    @objc func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let tab = HotwireTab.all.first(where: { navigator(for: $0)?.rootViewController === viewController }) else { return true }
        return shouldSelect(tab)
    }

    @available(iOS 18.0, *)
    @objc func tabBarController(_ tabBarController: UITabBarController, shouldSelectTab tab: UITab) -> Bool {
        guard let tab = HotwireTab.all.first(where: { $0.id == tab.identifier }) else { return true }
        return shouldSelect(tab)
    }
}
