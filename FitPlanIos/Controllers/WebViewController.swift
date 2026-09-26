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
    }

    // Screens that sign the user in declare "tab_bar": "hidden" in the path
    // configuration, since there is nothing to switch to until there is a session.
    private func updateTabBarVisibility() {
        let properties = Hotwire.config.pathConfiguration.properties(for: currentVisitableURL)
        tabBarController?.tabBar.isHidden = properties["tab_bar"] as? String == "hidden"
    }
}
