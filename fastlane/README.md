fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Generate new screenshots

### ios test

```sh
[bundle exec] fastlane ios test
```

[CI] Run Unit and UI Tests

### ios build

```sh
[bundle exec] fastlane ios build
```

[CI] Default build configuration

### ios release

```sh
[bundle exec] fastlane ios release
```

[CI] Upload a previous build app to TestFlight

### ios api_key

```sh
[bundle exec] fastlane ios api_key
```

[CI] Generate a fresh token to authenticate on the app store connect api

### ios swift_lint

```sh
[bundle exec] fastlane ios swift_lint
```

[CI] Check static code quality

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
