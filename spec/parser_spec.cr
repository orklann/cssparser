require "./spec_helper.cr"

module CssParser
  describe Parser do
    it "create new parser" do
      parser = Parser.new("font-name")
      parser.lexer.class.name.should eq("CssParser::Lexer")
    end

    it "parse component value as preserved token" do
      parser = Parser.new("14pt")
      ast = parser.parse_component_value
      case ast
      when ComponentValueNode
        value = ast.value
        case value
        when Token
          value.class.name.should eq("CssParser::Token")
          value.value.should eq("14pt")
        end
      end
    end

    it "parse curly block node" do
      parser = Parser.new("{14pt}")
      node = parser.parse_curly_block
      case node
      when CurlyBlockNode
        value = node.value[0].value
        case value
        when Token
          value.value.should eq("14pt")
        end
      end

      parser = Parser.new("{(}")
      node = parser.parse_curly_block
      case node
      when CurlyBlockNode
        node.value.size.should eq(0)
      end

      parser = Parser.new("{14pt")
      node = parser.parse_curly_block
      node.should eq(nil)
    end

    it "parse parenthesis block node" do
      parser = Parser.new("(14pt)")
      node = parser.parse_parenthesis_block
      case node
      when ParenthesisBlockNode
        value = node.value[0].value
        case value
        when Token
          value.value.should eq("14pt")
        end
      end

      parser = Parser.new("({)")
      node = parser.parse_parenthesis_block
      case node
      when ParenthesisBlockNode
        node.value.size.should eq(0)
      end

      parser = Parser.new("(14pt")
      node = parser.parse_parenthesis_block
      node.should eq(nil)
    end

    it "parse square block node" do
      parser = Parser.new("[14pt]")
      node = parser.parse_square_block
      case node
      when SquareBlockNode
        value = node.value[0].value
        case value
        when Token
          value.value.should eq("14pt")
        end
      end

      parser = Parser.new("[[14pt]")
      node = parser.parse_square_block
      case node
      when SquareBlockNode
        node.value.size.should eq(0)
      end

      parser = Parser.new("[14pt")
      node = parser.parse_square_block
      node.should eq(nil)
    end

    it "parse function block node" do
      parser = Parser.new("repeat(14pt)")
      node = parser.parse_function_block
      case node
      when FunctionBlockNode
        value = node.value[0].value
        case value
        when Token
          value.value.should eq("14pt")
        end
      end

      parser = Parser.new("repeat((14pt)")
      node = parser.parse_function_block
      case node
      when FunctionBlockNode
        node.value.size.should eq(0)
      end

      parser = Parser.new("repeat(14pt")
      node = parser.parse_function_block
      node.should eq(nil)
    end

    it "parse !important node" do
      parser = Parser.new("!important !important !notimportant")
      node = parser.parse_important
      node.class.name.should eq("CssParser::ImportantNode")

      node = parser.parse_important
      node.class.name.should eq("CssParser::ImportantNode")

      node = parser.parse_important
      node.should eq(nil)
    end

    it "parse declaration node" do
      parser = Parser.new("font-family: \"Times Roman\"")
      node = parser.parse_declaration
      case node
      when DeclarationNode
        node.ident_token.value.should eq("font-family")
        token = node.component_values[1].value
        case token
        when Token
          token.value.should eq("Times Roman")
        end
        node.important.should be_false
      end

      parser = Parser.new("font-family: \"Times Roman\" !important")
      node = parser.parse_declaration
      case node
      when DeclarationNode
        node.ident_token.value.should eq("font-family")
        token = node.component_values[1].value
        case token
        when Token
          token.value.should eq("Times Roman")
        end

        node.important.should be_true
      end
    end
  end
end
