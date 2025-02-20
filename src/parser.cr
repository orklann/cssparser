require "./lexer"

module CssParser
  class Parser
    property lexer : Lexer

    def initialize(@lexer)

    end
  end
end
