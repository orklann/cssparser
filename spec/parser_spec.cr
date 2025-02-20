require "./spec_helper.cr"

module CssParser
  describe Parser do
    it "create new parser" do
      lexer = Lexer.new("")
      parser = Parser.new(lexer)
      parser.lexer.should eq(lexer)
    end
  end
end
