require "./lexer"
require "./ast"

module CssParser
  class Parser
    property lexer : Lexer

    def initialize(string : String)
      @lexer = Lexer.new(string)
    end

    def parse_component_value
      token = @lexer.next_token_copy
      if token.preserved?
        ast = ComponentValueNode.new(token)
        return ast
      end
      return nil
    end

    def parse_curly_block
      token = @lexer.next_token_copy
      if token.type == Token::Kind::CURLY_BRACKET
        component_values = Array(ComponentValueNode).new
        while true
          saved_pos = @lexer.current_pos
          token = @lexer.next_token_copy
          if token.type != Token::Kind::CLOSING_CURLY_BRACKET
            @lexer.set_current_pos(saved_pos)
            value = parse_component_value.not_nil!
            component_values.push(value)
          else
            break
          end
        end
        node = CurlyBlockNode.new(component_values)
        return node
      end
      return nil
    end

    def parse_parenthesis_block
      token = @lexer.next_token_copy
      if token.type == Token::Kind::PARENTHESIS
        component_values = Array(ComponentValueNode).new
        while true
          saved_pos = @lexer.current_pos
          token = @lexer.next_token_copy
          if token.type != Token::Kind::CLOSING_PARENTHESIS
            @lexer.set_current_pos(saved_pos)
            value = parse_component_value.not_nil!
            component_values.push(value)
          else
            break
          end
        end
        node = ParenthesisBlockNode.new(component_values)
        return node
      end
      return nil
    end

    def parse_square_block
      token = @lexer.next_token_copy
      if token.type == Token::Kind::SQUARE_BRACKET
        component_values = Array(ComponentValueNode).new
        while true
          saved_pos = @lexer.current_pos
          token = @lexer.next_token_copy
          if token.type != Token::Kind::CLOSING_SQUARE_BRACKET
            @lexer.set_current_pos(saved_pos)
            value = parse_component_value.not_nil!
            component_values.push(value)
          else
            break
          end
        end
        node = SquareBlockNode.new(component_values)
        return node
      end
      return nil
    end

    def parse_function_block
      token = @lexer.next_token_copy
      if token.type == Token::Kind::FUNCTION
        component_values = Array(ComponentValueNode).new
        while true
          char = @lexer.peek_next_char
          if char != ')'
            value = parse_component_value.not_nil!
            component_values.push(value)
          else
            break
          end
        end
        node = FunctionBlockNode.new(component_values)
        return node
      end
      return nil
    end
  end
end
