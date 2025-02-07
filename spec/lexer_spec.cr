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

    it "is white spaces" do
      lexer = Lexer.new("")
      lexer.space?(' ').should be_true
      lexer.space?('\n').should be_true
      lexer.space?('\r').should be_true
      lexer.space?('\t').should be_true
      lexer.space?('\f').should be_true
      lexer.space?('a').should be_false
    end

    it "match unicodes" do
      lexer = Lexer.new("\\01")
      lexer.match_unicode

      lexer = Lexer.new("\\01afaf")
      lexer.match_unicode

      lexer = Lexer.new("\\01afaf\r\n")
      lexer.match_unicode

      lexer = Lexer.new("\\01afaf\n")
      lexer.match_unicode

      lexer = Lexer.new("\\01afaf ")
      lexer.match_unicode

      lexer = Lexer.new("\\01afaf\t")
      lexer.match_unicode

      lexer = Lexer.new("\\01afaf\f")
      lexer.match_unicode

      expect_raises(Exception, "match unicode macro failed") do
        lexer = Lexer.new("\\x000")
        lexer.match_unicode
      end

      expect_raises(Exception, "match unicode macro failed") do
        lexer = Lexer.new("abcdef")
        lexer.match_unicode
      end
    end
  end
end
