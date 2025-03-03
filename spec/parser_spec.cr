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
          ast.value.class.name.should eq("CssParser::Token")
          ast.value.value.should eq("14pt")
        end
      end
    end

    it "parse curly block node" do
      parser = Parser.new("{14pt}")
      node = parser.parse_curly_block
      case node
      when CurlyBlockNode
        value = node.value[0]
        value.class.name.should eq("CssParser::ComponentValueNode")
        value.value.value.should eq("14pt")
      end
    end
  end
end
