## 0.4.0

Bundle pre compiled css and source map files so that users don't need to compile this package's sass files in transformer phase.

Remove `package:scissors` dependency.

The e2e example has moved to the independent repository (https://github.com/ntaoo/material2_dart_e2e_example) to be more practical working example without relative path package dependencies.

## 0.3.0

Sync with the alpha.9 only for "Available" components.

(breaking): Changed the package layout to follow the convention.
`import 'package:material2_dart/material.dart';` to import the all components and core functions.

## 0.2.0

Sync with the alpha.8 only for "Available" components.

- Port Async tabs demo.
- Port button toggle component. 
- Port Slider component.

## 0.1.1

- Upgrade Angular to beta.21.
- Upgrade related packages and SDK constraints.
- Add a large number of analysis options for stricter type checking and better code style.
- Upgrade tests for angular beta.21.
- Also Upgrade demo.
 
### Bug fixes.

Fix `MdAnchor disabled` didn't work.

## 0.1.0

**All porting works have done for the current target (anuglar/material2 6/15/2016).**

- Port progress bar and its demo. (Without test code.)
- Port progress circle and its demo. (Without test code.)
- Port ally and its demo. (Without test code.)
- Port overlay and its demo. (Without test code.)
- Port portal demo.
- Port baseline demo.
- Relax the package version constraints.

## 0.0.11

- Move from `sass` to `scissors` again in order to fix many build errors.
- Move demo_app from weird web/ directory to example/ directory to follow the package convention.
- Confirm this package does not introduce any build errors now.
- Add prerequisites and improve usage on README.

## 0.0.10

- Port slide toggle and its demo. (Without test code.)
- Port radio and its demo. (Without test code.)
- Port grid list and its demo. (Without test code.)
- Rewrite README.

## 0.0.9

- Port checkbox. (Without enough test code.)
- Port input. (Without enough test code.)
- Port checkbox demo.
- Port input demo.
- Port tabs demo with a bug fix. Caution: async tabs doesn't work. See [issues/30](https://github.com/ntaoo/material2_dart/issues/30).
- Add a side nave link for [issues/29](https://github.com/ntaoo/material2_dart/issues/29).

## 0.0.8

- Port list demo.
- Port toolbar demo with bug fixes.
- Port sidenav demo with its bug fixes.

## 0.0.7

- Update existing code to original angular/material2's 497a3c1 (6/15/2016).
- Port card demo.
- Port icon demo with bug fixes.
- Port tabs.

## 0.0.6

- Fix md-card didn't work.
- Improve demo app code with sidenav, list, toolbar, button, icon. And add complete button demo (still have some problems).
- Instead of `scissors` package which requires `sassc`, adopt `sass` package for easier setup.

## 0.0.5

- Add card.


## 0.0.4+1

- Experimentally enable strong-mode.

## 0.0.4

- Add list.

## 0.0.3

- Add sidenav, toolbar, and icon.

## 0.0.1

- Initial version, with MdButton and the demo app.
