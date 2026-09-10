import Foundation

struct TurboNativeProject {
    private static let developmentURL = URL(string: "http://localhost:3000")!
    private static let productionURL  = URL(string: "https://fitplan.vip")!

    static var baseURL:   URL { developmentURL }
    static var homeURL:   URL { baseURL.appendingPathComponent("/") }
    static var signInURL: URL { baseURL.appendingPathComponent("/signin") }
}
