# skeptic

_Skeptic_ is a *very* experimental static code analyzer for Ruby 1.9. It points out annoying things in your Ruby code.

I am using it for a [Ruby course in the University of Sofia](http://fmi.ruby.bg/). All the assignments the students hand it should adhere to specific style, that is automatically checked with Skeptic. Assignments that fail to meet the criteria are rejected outright. The main assumption is the "theory" of constraints - when one operates under constraints, one is more creative and ends up learning more.

You should probably not use it for anything.

## Installation

Skeptic can be installed as a Ruby gem, either via `gem install skeptic`, or better yet via Bundler.

Make sure that you have the `aspell` package installed in your system, along with its shared libraries (`libaspell`). If you're on OS X, you can use [Homebrew](http://brew.sh/) to do that:

    brew install aspell

You may have to set the following ruby ENV variables. You can do this by adding them to your shell initialization file.

    export LANGUAGE=en_US.UTF-8
    export LC_CTYPE=en_US.UTF-8
    export LC_ALL=en_US.UTF-8

On other Linux/Unix distributions, you are free to use a package manager or another installation method of choice.

For Windows systems, check out [GNU Aspell for Win32](http://aspell.net/win32/). Install Aspell using the "Full Installer" linked in that page, then locate `aspell-15.dll` in the installation and copy it somewhere in your `PATH` as `aspell.dll`.

**A lot of people miss that**. You need to install an english dictionary from the list in the aspell home page(precompiled dictionaries section). Otherwise aspell will crash with segmentation fault if you try to use the `english-words-for-names' check.  

## Rules

Skeptic checks if the code complies to a number of rules and reports the violations. Here is a list of the rules:

* **Valid syntax** - skeptic can check if your syntax is valid.
* **Line length** - line length does not exceed a certain number.
* **Lines per method** - methods are at most N lines long. Ignores empty lines and lines with `end`
* **Max nesting depth** - at most N levels of nesting. Blocks, conditions and loops are considered a level of nesting.
* **Methods per class** - the number of methods per class does not exceed a certain number
* **No semicolons** - stops you from using semicolons as expression delimiters.
* **No trailing whitespace** - points out if your lines end on whitespace.
* **Naming conventions** - checks if the names of variables/methods/classes follow the conventions
* **No global variables** - does not allow the use of global variables
* **Max method arity** - limits the arguments count per method
* **Spaces around operators** - checks for spaces around operators
* **English words for names** - detection of non-English words in names

## Copyright

Copyright (c) 2011 Stefan Kanev. See LICENSE.txt for further details.
