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
        ast.value.class.name.should eq("CssParser::Token")
        ast.value.value.should eq("14pt")
      end
    end
  end
end
