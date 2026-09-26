import HotwireNative
import UIKit

final class WebViewController: HotwireWebViewController {

    private lazy var dismissModalButton = {
        UIBarButtonItem(image: UIImage(systemName: "chevron.down"), primaryAction: UIAction { [unowned self] _ in
            dismiss(animated: true)
        })
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // The right side belongs to bridge components like the form submit button.
        if presentingViewController != nil {
            navigationItem.leftBarButtonItem = dismissModalButton
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTabBarVisibility()
    }

    override func visitableDidRender() {
        super.visitableDidRender()
        updateTabBarVisibility()

        if let navigationController, let tabBarController = tabBarController as? TabBarController {
            tabBarController.pageDidRender(in: navigationController)
        }
    }

    // Screens that sign the user in declare "tab_bar": "hidden" in the path
    // configuration, since there is nothing to switch to until there is a session.
    private func updateTabBarVisibility() {
        guard let tabBarController else { return }

        let properties = Hotwire.config.pathConfiguration.properties(for: currentVisitableURL)
        let hidden = properties["tab_bar"] as? String == "hidden"

        // The bars are opaque, so screens stop above the tab bar. Without it,
        // extend the screen down into the space it leaves.
        tabBarController.tabBar.isHidden = hidden
        extendedLayoutIncludesOpaqueBars = hidden
        edgesForExtendedLayout = hidden ? .bottom : .all
        navigationController?.view.setNeedsLayout()
    }
}
