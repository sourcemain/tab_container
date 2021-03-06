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