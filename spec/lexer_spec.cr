require "./spec_helper.cr"

module CssParser
  describe Lexer do
    it "get next char" do
      lexer = Lexer.new("div {}")
      char = lexer.current_char
      char.should eq('d')
      char = lexer.next_char
      char.should eq('i')
    end
  end
end
