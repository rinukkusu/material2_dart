# material2_dart

Porting angular/material2 to the Dart version.

## Purpose

* To provide another UI library option for demo apps.
* To understand how to compose UI components with angular2.
* To clarify the API compatibility between the TypeScript version and the Dart version.

I have been maintaining the same API and internal structure as much as I can for easy side by side comparison between the Dart version and the TypeScript version.

**I don't recommend to use this library for serious apps** because the original TypeScript version has still been in alpha phase, and this is nothing more than a porting work that may contain another bugs.

## Angular2 Testing.

    // Run test server.
    pub serve

    // Run tests on dartium.
    pub run test --pub-serve=8081 -p dartium
