## 3.5.1

Optimise clipping.

## 3.5.0

Add new TabContainerFocus widget for wrapping TabContainer with a basic focus implementation.

## 3.4.0

Change sizing behaviour to wrap the child and add support for trackpad scrolling.

## 3.3.1

Update README.

## 3.3.0

Update default semantics implementation and allow total customisation of semantics. See README.

## 3.2.0

Features:
 - Add implicit scrolling.
 - Add 'onIncrease' and 'onDecrease' semantics configuration.

## 3.1.2

Update TabController management.

## 3.1.1

Fix bug on mobile caused by matrix transform.

## 3.1.0

Features:
 - Tab bar automatically becomes scrollable if there are too many tabs. Suggestion: specify tabMinLength.
 - Improved animation quality.

## 3.0.0

BREAKING:
 - TabContainer now extends StatefulWidget instead of ImplicitlyAnimatedWidget.
 - Accepts native TabController instead of custom TabContainerController.
 - Now hit tests widgets within the tabs so MouseRegion and Buttons will work inside tabs.
 - No longer accepts a List<String> for tabs. Suggestion: replace raw strings with Text widgets.
 - Allow different border radius for every corner. Suggestion: use properties borderRadius and
tabBorderRadius instead of radius.
 - Allow limiting the maximum length of each tab.
 - Allow a single child to be supplied instead of children so TabContainer can serve as a switch
if used with a manual TabController.
 - Improved performance and changed some property names.

## 2.0.0

BREAKING:
 - Remove type checking of 'tabs' behind the scenes in favor of greater clarity: it is now on the 
developer to specify the type of 'tabs' using the new 'isStringTabs' parameter. Set it to 'false' 
if your 'tabs' value is a 'List<Widget>'; leave it as 'true' if 'tabs' is a 'List<String>'.
 - Update example/lib/main.dart to reflect changes.
 - Update pubspec.yaml.
 - Update README.md.

## 1.2.2

Fix static analysis error

## 1.2.1

Fix static analysis error

## 1.2.0

Add 'enableFeedback' property for acoustic and/or haptic feedback on tab gestures.
Update REAMDE.md.

## 1.1.0

Major improvements:
 - Add 'tabStart' and 'tabEnd' properties. Specify where, along the side, tabs begin and end.
 - Refactor child hit testing.
 - Update README.md and example/lib/main.dart to reflect changes.

## 1.0.1

Fix 'TabContainerController' listener removal.

## 1.0.0+2

Fix CHANGELOG.md, pubspec.yaml

## 1.0.0+1

Update README.md

## 1.0.0

BREAKING:
 - Remove unnecessary 'usesTextWidget' property. Type of 'tabs' is checked automatically now.
 - Add 'childPadding' property, which specifies the padding to be applied to all 'children'.
 - Update example/lib/main.dart to reflect changes.
 - Update pubspec.yaml.
 - Update README.md.

## 0.0.1+2

Update pubspec.yaml

## 0.0.1+1

Move example file and update README.md

## 0.0.1

Initial development release.