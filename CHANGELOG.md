## 0.0.12 (2015-10-14)
Bugfixes:
  - Fix range operators handling and stop detecting splat operators in beginning of collection literals

## 0.0.11 (2014-10-27)
Bugfixes:
  - Fix issue with using mixed parameter types ([s2gatev](https://github.com/s2gatev))

## 0.0.10 (2014-10-27)

Bugfixes:
  - Fix handling of top-level methods in max-method-arity

## 0.0.9 (2014-10-24)

Bugfixes:
  - Fix issue with passing method chain as block ([s2gatev](https://github.com/s2gatev))

## 0.0.8 (2014-10-12)

Features:
  - Add a rule for max method arity (thanks to [milanov](https://github.com/milanov))
  - Add support for checking recursively whole directories

Bugfixes:
  - Fix detection of unary operators
  - Add installation instructions in the readme (thanks to [mitio](https://github.com/mitio))
  - Fix handling of case statements without a testable in max nesting depth rule

## 0.0.7 (2013-12-15)

Bugfixes:
  - Fix crashing in naming conventions rule
  - Stop detecting unary - in space around operators rule
  - Improve space around operators detection using ast context info

## 0.0.6 (2013-12-14)

Bugfixes:
  - Refine bad naming detection


## 0.0.5 (2013-11-15)

Features:

  - Add a rule for whitespace around operators
  - Add a rule for naming conventions (snake case, camel case, screaming snake case)
  - Add a rule that allows only definitions of names containing valid English words
  - Add a rule that detects the use of global variables

Bugfixes:

  - Fix counting class methods in `--methods-per-class` rule
