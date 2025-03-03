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
    end
  end
end
