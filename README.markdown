# skeptic

_Skeptic_ is a *very* experimental static code analyzer for Ruby 1.9. It points out annoying things in your Ruby code.

I am using it for a [Ruby course in the University of Sofia](http://fmi.ruby.bg/). All the assignments the students hand it should adhere to specific style, that is automatically checked with Skeptic. Assignments that fail to meet the critera are rejected outright. The main assumption is the "theory" of constraints - when one operates under constraints, one is more creative and ends up learning more.

You should probably not use it for anythin.

## Rules

Skeptic checks if the code complies to a number of rules and reports the violations. Here is a list of the rules:

* **Valid syntax** - skeptic can check if your syntax is valid.
* **Line length** - line length does not exceed a certain number.
* **Lines per method** - methods are at most N lines long. Ignores empty lines and lines with `end`
* **Max nesting depth** - at most N levels of nesting. blocks, conditions and loops are considered a level of nesting.
* **No semicolons** - stops you from using semicolons as expression delimiters.
* **No trailing whitespace** - points out if your lines end on whitespace.

## Copyright

Copyright (c) 2011 Stefan Kanev. See LICENSE.txt for further details.
