# FitPlan iOS

iOS client for **FitPlan**, a platform for managing personalized diet and workout records.

This app is not a standalone rewrite: it is a [Turbo Native](https://github.com/hotwired/turbo-ios) shell that renders the FitPlan Rails application inside a `WKWebView` and promotes selected parts of the interface to native iOS components through the [Strada](https://github.com/hotwired/strada-ios) bridge.

> **Web application (backend + frontend):** https://github.com/nicollinoxx/FitPlan
>
> The iOS app has no business logic or database of its own. Every screen, route and rule comes from the Rails app above, so that repository is required to run this one.

Built as part of an undergraduate final project (TCC).

## Technologies

- Swift 5
- Turbo iOS 7.0.1
- Strada 1.0.0-beta1
- UIKit / `WKWebView`
- Storyboards
- Swift Package Manager
- Minimum iOS version: 16.3

## Prerequisites / Dependencies

- macOS
- Xcode
- iOS 16.3 or later
- A running instance of [FitPlan](https://github.com/nicollinoxx/FitPlan)

The project uses Swift Package Manager to fetch the Turbo iOS and Strada dependencies automatically.

## Setup

1. Start the Rails app from the [FitPlan](https://github.com/nicollinoxx/FitPlan) repository on port `3000`.

2. Point the app at that instance in `FitPlanIos/FitPlanIos.swift`:

   ```swift
   private static let developmentURL = URL(string: "http://localhost:3000")!
   private static let productionURL = URL(string: "https://fitplan.vip")!

   static var baseURL: URL { developmentURL }
