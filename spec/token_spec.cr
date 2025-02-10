require "./spec_helper"

module CssParser
  describe Token do
    it "has correct EOF type by default" do
      token = Token.new
      token.type.should eq(Token::Kind::UNKNOWN)
    end

    it "has IDENT type" do
      token = Token.new
      token.type = :IDENT
      token.type.should eq(Token::Kind::IDENT)
    end
  end
end
