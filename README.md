# FitPlan iOS

iOS client for **FitPlan**, a platform for managing personalized diet and workout records.

This app is not a standalone rewrite: it is a [Hotwire Native](https://native.hotwired.dev) shell that
renders the FitPlan Rails application inside a `WKWebView` and promotes selected parts of the interface to
native iOS components through bridge components.

> **Web application (backend + frontend):** https://github.com/nicollinoxx/FitPlan
>
> The iOS app has no business logic or database of its own. Every screen, route and rule comes from the
> Rails app above, so that repository is required to run this one.

Built as part of an undergraduate final project (TCC).

## Technologies

- Swift 5
- Hotwire Native iOS 1.3.1
- UIKit / `WKWebView`
- Swift Package Manager
- Minimum iOS version: 16.3

## Prerequisites / Dependencies

- macOS
- Xcode
- iOS 16.3 or later
- A running instance of [FitPlan](https://github.com/nicollinoxx/FitPlan)

The project uses Swift Package Manager to fetch Hotwire Native automatically.

## Setup

1. Start the Rails app from the [FitPlan](https://github.com/nicollinoxx/FitPlan) repository on port `3000`.

2. Point the app at that instance in `FitPlanIos/FitPlanIos.swift`:

   ```swift
   private static let developmentURL = URL(string: "http://localhost:3000")!
   private static let productionURL = URL(string: "https://fitplan.vip")!

   static var baseURL: URL { developmentURL }
   ```

   The simulator shares the host's network, so `localhost` works as is. On a physical device, use the
   machine's IP on the local network instead.

3. Build and run from Xcode.

## How the integration works

### Tab bar

`Controllers/TabBarController.swift` declares five tabs — Sheets, Shares, Dashboard, Social and Profile —
and each one gets its own navigator and navigation stack. The start page of every tab is a real route of
the Rails app, listed in `FitPlanIos.swift`; adding or moving a tab means changing that list, not writing a
screen.

Tapping the tab you are already on sends it back to its start page, and a tab whose page was rendered under
a different Rails session is reset the next time you open it, so signing in or out never leaves a tab showing
the previous user.

### Path configuration

`Resources/path-configuration.json` maps URL patterns from the Rails app to presentations — whether a path
opens as a modal, whether it replaces the tab root, whether it hides the tab bar, and which view controller
renders it. Adding a route to the Rails app that needs different presentation means adding a rule here.

Rules are matched against the path alone (`matchQueryStrings = false`), so filtered URLs such as
`/sheets?type=diet` still resolve to the sheets start page.

### Bridge components

Each native component has a counterpart Stimulus controller in the Rails app. Both sides must agree on the
component name and on the event names, so **these pairs are the contract between the two repositories**:

| Component name  | iOS (`FitPlanIos/Strada/`)     | Rails (`app/javascript/controllers/bridge/`) | Behavior                                       |
| --------------- | ------------------------------ | -------------------------------------------- | ---------------------------------------------- |
| `form`          | `FormComponent.swift`          | `form_controller.js`                         | Moves a form's submit button into the nav bar   |
| `nav-button`    | `NavButtonComponent.swift`     | `nav_button_controller.js`                   | Renders a web link as a native nav bar button   |
| `flash-message` | `FlashMessageComponent.swift`  | `flash_message_controller.js`                | Shows Rails flash messages as a native toast    |
| `menu`          | `MenuComponent.swift`          | `menu_controller.js`                         | Shows a group of links as a native action sheet |

Components are registered in `Delegates/AppDelegate.swift` and announced to the server through the user
agent, which is how the Rails side knows which components this client supports. On the Rails side the
integration relies on the `@hotwired/hotwire-native-bridge` importmap pin.

## Notes

- **Social sign in:** Google and Facebook are hidden inside the app. The provider flow opens in a browser
  whose cookie jar is separate from the `WKWebView`'s, so the session it establishes never reaches the app.
  Turning it back on means adopting the native SDKs.
- **Distribution:** the app is set up for development only; there is no signing or release configuration yet.
