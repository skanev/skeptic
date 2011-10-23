Feature: Running skeptic
  Scenario: Nothing to complain about
    Given a file named "input.rb" with:
      """
      foo
      """
    When I run `skeptic input.rb`
    Then it should pass with:
      """
      OK
      """

  Scenario: Banishing semicolons
    Given a file named "input.rb" with:
      """
      foo; bar
      """
    When I run `skeptic --semicolons input.rb`
    Then it should fail with:
      """
      Semicolons
      * You have a semicolon at line 1, column 3
      """

  Scenario: Limiting method length
    Given a file named "input.rb" with:
      """
      class Foo
        def bar
          one
          two
          three
        end
      end
      """
    When I run `skeptic --method-length 2 input.rb`
    Then it should fail with:
      """
      Number of lines per method
      * Foo#bar is 3 lines long
      """

  Scenario: Limiting depth of nesting
    Given a file named "input.rb" with:
      """
      class Foo
        def bar
          while true
            if false
              really?
            end
          end
        end
      end
      """
    When I run `skeptic --max-nesting 1 input.rb`
    Then it should fail with:
      """
      Deep nesting
      * Foo#bar has 2 levels of nesting: while > if
      """

  Scenario: Limiting number of methods per class
    Given a file named "input.rb" with:
      """
      class Foo
        def bar; end
        def baz; end
      end
      """
    When I run `skeptic --methods-per-class 1 input.rb`
    Then it should fail with:
      """
      Number of methods per class
      * Foo has 2 methods: #bar, #baz
      """
