import Foundation

enum FitPlan {
    private static let developmentURL = URL(string: "http://localhost:3000")!
    private static let productionURL  = URL(string: "https://fitplan.vip")!

    static var baseURL:   URL { developmentURL }
    static var signInURL: URL { baseURL.appendingPathComponent("sign_in") }

    // Cookie the Rails app stores the signed-in session under (see SessionsController).
    static let sessionCookie = "session_token"

    // Start location of each tab. Every path below is a real top-level route of
    // the FitPlan Rails app (see its config/routes.rb).
    static var sheetsURL:    URL { baseURL.appendingPathComponent("sheets") }
    static var sharesURL:    URL { baseURL.appendingPathComponent("sheets/shares") }
    static var dashboardURL: URL { baseURL.appendingPathComponent("dashboard") }
    static var socialURL:    URL { baseURL.appendingPathComponent("social/profiles") }
    static var profileURL:   URL { baseURL.appendingPathComponent("identity/profile") }
}
