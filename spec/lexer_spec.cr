require "./spec_helper.cr"

module CssParser
  describe Lexer do
    it "gets next char" do
      lexer = Lexer.new("div {}")
      char = lexer.current_char
      char.should eq('d')
      char = lexer.next_char
      char.should eq('i')
    end

    it "gets string in range" do
      lexer = Lexer.new("div {}")
      lexer.next_char
      lexer.next_char
      lexer.next_char
      s1 = lexer.string_range(0)
      s1.should eq("div")
    end
  end
end
