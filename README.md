TWSReleaseNotesView
===================

Among other crazy features, iOS 7 enables users to have automatic updates for their apps, wiping away the infamous App Store badge. This is really convenient both for users and developers, but it comes with a couple of downsides:

* users are not aware about the changes introduced in the last update, unless they explicitly open the App Store page to check the last release notes;
* developers who spend their time working on well-written release notes lose their chance to inform and communicate with their users.

## So what?

TWSReleaseNotesView is a simple way to address those issues. It comes with a straightforward API which enables developers to show in-app release notes with a fully customizable popup view.

## How to get started
1. Download the TWSReleaseNotesView folder and add it to your project
2. In addition to the default `UIKit`, `CoreGraphics` and `Foundation`, the following frameworks are needed: `Accelerate` and `Quartzcore`. If any of them is missing in your Frameworks list, follow these steps in order to add them:
  * Go to the "Build Phases" tab for the project target you're interested in
  * Click the `+` button in the collapsible "Link Binary With Libraries" section.
  * Add the missing frameworks.
3. That's it!

## Features
* Version check in order to choose whether showing the release notes view or not.
* Local release notes view with custom appearance and text information.
* Remote release notes view using the application's Apple ID, in order to retrieve the last release notes directly from App Store, using the iTunes Search API.
