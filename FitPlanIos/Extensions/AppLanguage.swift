import Foundation

/// The language the Rails app renders in. People can pick one apart from the
/// device's, so the app's own texts follow it instead of the device's.
enum AppLanguage {

    /// Where to look texts up, e.g. `String(localized: "Sheets", bundle: AppLanguage.bundle)`.
    private(set) static var bundle = Bundle.main

    /// Switches to `code` from the Rails app's locale cookie, or back to the
    /// device's language when there is no cookie.
    static func use(_ code: String?) {
        let path = code.flatMap { Bundle.main.path(forResource: $0, ofType: "lproj") }
        bundle = path.flatMap(Bundle.init(path:)) ?? .main
    }
}
