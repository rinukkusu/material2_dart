# material2_dart

[angular/material2](https://github.com/angular/material2) for Dart.

## Porting Status

### Current target.

497a3c1 (commit sha1 6/15/2016)

### Ported components.

* Button
* Card
* Icon
* List (The demo comming soon)
* SideNav (The demo comming soon)
* Tabs  (The demo comming soon)
* Toolbar  (The demo comming soon)

## Purpose

* To provide another UI library option for demo apps.
* To understand how to compose UI components with angular2.
* To clarify the API compatibility between the TypeScript version and the Dart version.

I have been maintaining the same API and internal structure as much as I can for easy side by side comparison between the Dart version and the TypeScript version.

## Angular2 Testing.

    // Run test server.
    pub serve

    // Run tests on dartium.
    pub run test --pub-serve=8081 -p dartium
