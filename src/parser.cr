require "./lexer"
require "./ast"

module CssParser
  class Parser
    property lexer : Lexer

    def initialize(string : String)
      @lexer = Lexer.new(string)
    end

    def parse_component_value
      token = @lexer.next_token
      if token.preserved?
        ast = ComponentValueNode.new(token)
        return ast
      end
      return nil
    end
  end
end
