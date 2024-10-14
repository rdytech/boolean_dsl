class BooleanDsl::Parser < Parslet::Parser
  # Spaces
  rule(:space) { match('\s').repeat(1) }
  rule(:space?) { space.maybe }

  # Literals
  rule(:sign) { match('[+-]') }
  rule(:digit) { match('[0-9]') }
  rule(:digits) { digit.repeat(1) }
  rule(:decimal_fragment) { digits >> str(".") >> digits }

  rule(:integer) { (sign.maybe >> digits).as(:integer) >> space? }
  rule(:decimal) { (sign.maybe >> decimal_fragment).as(:decimal) >> space? }
  rule(:percentage) { (sign.maybe >> (decimal_fragment | digits) >> str("%")).as(:percentage) >> space? }

  rule(:date) { (digit.repeat(1,2) >> str("/") >> digit.repeat(1,2) >> str("/") >> digit.repeat(4,4)).as(:date) }

  rule(:string_content) { (str("'").absent? >> any).repeat }
  rule(:string) { str("'") >> string_content.as(:string) >> str("'") >> space? }

  rule(:array) { str('[') >> space? >> array_list.repeat(0,1).as(:array) >> str(']') >> space? }
  rule(:array_list) { array_element >> (str(',') >> space? >> array_element).repeat }
  rule(:array_element) { integer | decimal | string }

  rule(:attribute) do
    (match('[A-Za-z_]') >> match('[A-Za-z_0-9]').repeat >> str('?').maybe).as(:attribute) >> space?
  end

  # Negation
  rule(:negation) { str('!') >> attribute.as(:negation) }

  # Elements
  rule(:element) { negation | date | percentage | decimal | integer | string | array | attribute }

  # Booleans are rules that will evaluate to a true or false result
  rule(:boolean) { value_comparison | negation | attribute }
  rule(:boolean_sub) { parens | boolean }

  # Operators (Comparison)
  rule(:comparison_operator) do
    (str('==') | str('!=') | str('<=') | str('>=') | str('<') | str('>') | str('includes') | str('excludes')).as(:comparison_operator) >> space?
  end
  rule(:inclusion_comparison) { (array | attribute).as(:left) >> comparison_operator >> element.as(:right) >> space? }
  rule(:value_comparison) { element.as(:left) >> comparison_operator >> element.as(:right) >> space? }

  # Operators (Boolean)
  rule(:boolean_operator) { (str('and') | str('or')).as(:boolean_operator) >> space? }
  rule(:boolean_comparison) { boolean_sub.as(:left) >> boolean_operator >> expression.as(:right) >> space? }

  rule(:parens) { str('(') >> expression.maybe.as(:expression) >> space? >> str(')') >> space? }

  rule(:expression) { boolean_comparison | parens | inclusion_comparison | value_comparison | element }
  root(:expression)
end

