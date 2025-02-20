require "./lexer"

module CssParser
  class Parser
    property lexer : Lexer

    def initialize(string : String)
      @lexer = Lexer.new(string)
    end
  end
end
