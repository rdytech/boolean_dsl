# Boolean DSL

[![Code Climate](https://codeclimate.com/github/jobready/boolean_dsl.png)](https://codeclimate.com/github/jobready/boolean_dsl)
[![Test Coverage](https://codeclimate.com/github/jobready/boolean_dsl/badges/coverage.svg)](https://codeclimate.com/github/jobready/boolean_dsl)
[![Build status](https://badge.buildbox.io/adb8860e18e1f4c6e45f7744dffcc99c4fc1a44fc355a9bc24.svg)](https://buildbox.io/accounts/jobready/projects/boolean-dsl)

Boolean DSL is a simple boolean language for creating business rules

## Installation

Add this line to your application's Gemfile:

    gem 'boolean_dsl'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install boolean_dsl

## Usage

A **context** is simply a Ruby object. A **script** is a string of our DSL consisting of an **expression**
(described below). The result of the expression will be true or false, and that is what `BooleanDsl::Evaluator#outcome`
will return.

```ruby
require 'boolean_dsl'

context = Context.new
script = "(1 < 4 or 5 < 4) and (1 == 1 and alpha == 1)"
BooleanDsl::Evaluator.new(script, context).outcome

```

**Attribute** references (as described below), are simply the names of method on the context. i.e. in the example above,
it will call the `alpha` method of the `context`.


## DSL

Our DSL consists of these components:

* **string**, a sequence of characters, delimited by '' (single quotes),
  may contain any character other than a single quote. Examples:

      'alpha'
      'What is your name?'

* **integer**, a sequence of [+-]?[0-9]\*. Examples:

      0
      -654
      458457474

* **decimal**, a sequence of [+-]?[0-9]\*.[0-9]\*. Examples:

      0.123
      -45.78

* **percentage**, a sequence of [+-]?[0-9]\*(.[0-9])?%\*. Examples:

      43.56%
      -20%

* **date**, a sequence of [0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4}. Examples:

      9/2/2024
      31/12/2024

* **array**, a comma separated list of integer, decimal or string elements wrapped by [] (square brackets)

      [1,2,3]

* **attribute** reference, a sequence of [A-z\_][A-z0-9\_]\*[?]. When an attribute reference is evaluated,
  the context.send(attribute_reference) is called, and the result is used as the attribute's value.
  An attribute may optionally be prefixed by a ! (exclamation point). The result is the logial NOT of the
  attribute's value. Examples:

      beta
      Apple_Tree
      what_i5_YOUR_name?
      !beta
      !Apple_Tree
      !what_i5_YOUR_name?

* **element** is one of a **string**, **date**, **percentage**, **decimal**, **integer**, **array** or **attribute**.

* **comparison** consists of an **element**, followed by one of ==, !=, <, >, <=, >=, includes, excludes (the operator)
  followed by another **element**. When a comparison is evaluated, the 2 elements are compared using the operater
  supplied. The comparison follows Ruby evaluation rules. The result is used as the result of the comparison. Examples:

      1 < 2
      'test' == beta
      alpha != delta
      8 >= 1
      [1,2,3] includes 3
      start_date > 1/9/2024

* **boolean** expression consists of a left side, followed by one of _and_, _or_ (the operator),
  followed by a right side.

  The left side consists of a **attribute** or a **comparison**.
  The right side consists of an **expression**.

  When the boolean expression is evaluated, the results of the 2 sides are evaluated against the operator. The
  evaluation follows Ruby rules, including short-circuiting.

  The boolean expression may optionally be wrapped in () (parentheses), which forces the content of the parentheses
  to be evaluated independently of the rest of the script (i.e. it forces operator precedence). Examples:

      1 < 2 and 3 < 4
      beta or gamma != 'test'
      2 < 10 or (potato and 1 != 10)
      (6 > 7)

* **expression** is one of a **boolean**, **comparison**, or **element**. When the expression is evaluated, the result
  is the result of the boolean, comparison, or element.

  The expression may optionally be wrapped in () (parentheses), , which forces the content of the parentheses
  to be evaluated independently of the rest of the script (i.e. it forces operator precedence). Examples:

      8 >= 5
      beta == '1' or delta == '3'
      1 < 2 and 'alpha' == 'alpha' and 7 < 12
      8 == 8 or (beta != gamma and (delta > yotta))

Each component listed above may be surrounded by a single space; in the examples above, we have done this.

## Contributing

1. Fork it ( http://github.com/jobready/boolean_dsl/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
