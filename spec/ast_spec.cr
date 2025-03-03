require "./spec_helper"

module CssParser
  describe DeclarationNode do
    it "create DeclarationNode instance" do
      ident_token = Token.new
      ident_token.type = :IDENT
      componet_value = Token.new
      componet_value.type = :IDENT

      declaration_node = DeclarationNode.new(ident_token, componet_value)

      declaration_node.ident_token.type.should eq(Token::Kind::IDENT)
      declaration_node.componet_value.type.should eq(Token::Kind::IDENT)
    end
  end
end
