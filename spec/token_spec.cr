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

    it "checks preserved token" do
      token = Token.new
      token.type = :FUNCTION
      token.preserved?.should be_false

      token = Token.new
      token.type = :SQUARE_BRACKET
      token.preserved?.should be_false

      token = Token.new
      token.type = :PARENTHESIS
      token.preserved?.should be_false

      token = Token.new
      token.type = :CURLY_BRACKET
      token.preserved?.should be_false

      token = Token.new
      token.type = :S
      token.preserved?.should be_true

      token = Token.new
      token.type = :IDENT
      token.preserved?.should be_true
    end
  end
end
