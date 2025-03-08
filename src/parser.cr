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
      if token.preserved? && token.type != Token::Kind::EOF
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
          if token.type == Token::Kind::EOF
            return nil
          end
          if token.type != Token::Kind::CLOSING_CURLY_BRACKET
            @lexer.set_current_pos(saved_pos)
            value = parse_component_value
            if value == nil
              break
            else
              component_values.push(value.not_nil!)
            end
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
          if token.type == Token::Kind::EOF
            return nil
          end
          if token.type != Token::Kind::CLOSING_PARENTHESIS
            @lexer.set_current_pos(saved_pos)
            value = parse_component_value
            if value == nil
              break
            else
              component_values.push(value.not_nil!)
            end
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
          if token.type == Token::Kind::EOF
            return nil
          end
          if token.type != Token::Kind::CLOSING_SQUARE_BRACKET
            @lexer.set_current_pos(saved_pos)
            value = parse_component_value
            if value == nil
              break
            else
              component_values.push(value.not_nil!)
            end
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
      if token.type == Token::Kind::IDENT
        ident_token = token
        token = @lexer.next_token_copy
        if token.type == Token::Kind::FUNCTION
          component_values = Array(ComponentValueNode).new
          while true
            char = @lexer.peek_next_char
            if char == '\0'
              return nil
            end
            if char != ')'
              value = parse_component_value
              if value == nil
                break
              else
                component_values.push(value.not_nil!)
              end
            else
              break
            end
          end
          node = FunctionBlockNode.new(ident_token, component_values)
          return node
        end
      end
      return nil
    end

    def parse_important
      if @lexer.current_char == '!'
        @lexer.next_char
        token = @lexer.next_token_copy
        while token.type == Token::Kind::S
          token = @lexer.next_token_copy
        end
        if token.type == Token::Kind::IDENT && token.value == "important"
          saved_pos = @lexer.current_pos
          token = @lexer.next_token_copy
          while token.type == Token::Kind::S
            saved_pos = @lexer.current_pos
            token = @lexer.next_token_copy
          end
          @lexer.set_current_pos(saved_pos)
          return ImportantNode.new
        else
          return nil
        end
      end
      return nil
    end

    def parse_declaration
      token = @lexer.next_token_copy
      if token.type == Token::Kind::IDENT
        ident = token
        token = @lexer.next_token_copy
        while token.type == Token::Kind::S
          token = @lexer.next_token_copy
        end
        if token.type == Token::Kind::COLON
          component_values = Array(ComponentValueNode).new
          while true
            saved_pos = @lexer.current_pos
            important = parse_important
            if important == nil
              @lexer.set_current_pos(saved_pos)
              component_value = parse_component_value
              if component_value == nil
                break
              else
                component_values << component_value.not_nil!
              end
            else
              return DeclarationNode.new(ident, component_values, true)
            end
          end
          return DeclarationNode.new(ident, component_values, false)
        end
        return nil
      end
      return nil
    end
  end
end
