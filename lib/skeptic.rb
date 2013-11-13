require 'ripper'

require 'skeptic/environment'
require 'skeptic/scope'
require 'skeptic/sexp_visitor'

require 'skeptic/rules/check_syntax'
require 'skeptic/rules/max_nesting_depth'
require 'skeptic/rules/methods_per_class'
require 'skeptic/rules/lines_per_method'
require 'skeptic/rules/no_semicolons'
require 'skeptic/rules/line_length'
require 'skeptic/rules/no_trailing_whitespace'
require 'skeptic/rules/no_global_variables'

require 'skeptic/rule_table'
require 'skeptic/rules'
require 'skeptic/critic'
