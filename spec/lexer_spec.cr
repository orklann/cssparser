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
      lexer.match_unicode?.should be_true

      lexer = Lexer.new("\\01afaf")
      lexer.match_unicode?.should be_true

      lexer = Lexer.new("\\01afaf\r\n")
      lexer.match_unicode?.should be_true

      lexer = Lexer.new("\\01afaf\n")
      lexer.match_unicode?.should be_true

      lexer = Lexer.new("\\01afaf ")
      lexer.match_unicode?.should be_true

      lexer = Lexer.new("\\01afaf\t")
      lexer.match_unicode?.should be_true

      lexer = Lexer.new("\\01afaf\f")
      lexer.match_unicode?.should be_true

      lexer = Lexer.new("\\x000")
      lexer.match_unicode?.should be_false

      lexer = Lexer.new("abcdef")
      lexer.match_unicode?.should be_false
    end

    it "match escape" do
      lexer = Lexer.new("\\01afaf")
      lexer.match_escape?.should be_true

      lexer = Lexer.new("\\z")
      lexer.match_escape?.should be_true

      lexer = Lexer.new("abc")
      lexer.match_escape?.should be_false
    end

    it "match nonascii" do
      lexer = Lexer.new("\xa0")
      lexer.match_nonascii?.should be_true

      lexer = Lexer.new("世界")
      lexer.match_nonascii?.should be_true

      lexer = Lexer.new("a")
      lexer.match_nonascii?.should be_false
    end

    it "match nmstart" do
      lexer = Lexer.new("_abc")
      lexer.match_nmstart?.should be_true

      lexer = Lexer.new("世界")
      lexer.match_nmstart?.should be_true

      lexer = Lexer.new("\\01afaf")
      lexer.match_nmstart?.should be_true

      lexer = Lexer.new("\r")
      lexer.match_nmstart?.should be_false

      lexer = Lexer.new("ABC")
      lexer.match_nmstart?.should be_false
    end

    it "match nmchar" do
      lexer = Lexer.new("a")
      lexer.match_nmchar?.should be_true

      lexer = Lexer.new("z")
      lexer.match_nmchar?.should be_true

      lexer = Lexer.new("f")
      lexer.match_nmchar?.should be_true

      lexer = Lexer.new("0")
      lexer.match_nmchar?.should be_true

      lexer = Lexer.new("9")
      lexer.match_nmchar?.should be_true

      lexer = Lexer.new("5")
      lexer.match_nmchar?.should be_true

      lexer = Lexer.new("_")
      lexer.match_nmchar?.should be_true

      lexer = Lexer.new("-")
      lexer.match_nmchar?.should be_true

      lexer = Lexer.new("世界")
      lexer.match_nmchar?.should be_true

      lexer = Lexer.new("\\z")
      lexer.match_nmchar?.should be_true

      lexer = Lexer.new("A")
      lexer.match_nmchar?.should be_false
    end

    it "return IDENT token" do
      lexer = Lexer.new("-name")
      token = lexer.next_token
      token.type.should eq(Token::Kind::IDENT)
      token.value.should eq("-name")
    end

    it "return ATKEYWORD token" do
      lexer = Lexer.new("@-name")
      token = lexer.next_token
      token.type.should eq(Token::Kind::ATKEYWORD)
      token.value.should eq("@-name")
    end

    it "match string1" do
      lexer = Lexer.new("\"abc\"")
      lexer.match_string1?.should be_true

      lexer = Lexer.new("\"ABC\"")
      lexer.match_string1?.should be_true

      lexer = Lexer.new("\"ABC世界\"")
      lexer.match_string1?.should be_true

      lexer = Lexer.new("\"\\\n\\\r\\\f\\\r\n\"")
      lexer.match_string1?.should be_true

      lexer = Lexer.new("a\"")
      lexer.match_string1?.should be_false
    end

    it "match string2" do
      lexer = Lexer.new("'abc'")
      lexer.match_string2?.should be_true

      lexer = Lexer.new("'ABC'")
      lexer.match_string2?.should be_true

      lexer = Lexer.new("'ABC世界'")
      lexer.match_string2?.should be_true

      lexer = Lexer.new("'\\\n\\\r\\\f\\\r\n'")
      lexer.match_string2?.should be_true

      lexer = Lexer.new("a\"")
      lexer.match_string2?.should be_false
    end

    it "match nl" do
      lexer = Lexer.new("\r")
      lexer.match_nl?.should be_true

      lexer = Lexer.new("\n")
      lexer.match_nl?.should be_true

      lexer = Lexer.new("\r\n")
      lexer.match_nl?.should be_true

      lexer = Lexer.new("\f")
      lexer.match_nl?.should be_true
    end

    it "return STRING token" do
      lexer = Lexer.new("'abc'")
      token = lexer.next_token
      token.type.should eq(Token::Kind::STRING)


      lexer = Lexer.new("'ABC'")
      token = lexer.next_token
      token.type.should eq(Token::Kind::STRING)

      lexer = Lexer.new("'ABC世界'")
      token = lexer.next_token
      token.type.should eq(Token::Kind::STRING)

      lexer = Lexer.new("'\\\n\\\r\\\f\\\r\n'")
      token = lexer.next_token
      token.type.should eq(Token::Kind::STRING)
    end

    it "match name" do
      lexer = Lexer.new("_abc")
      lexer.match_name?.should be_true

      lexer = Lexer.new("abc")
      lexer.match_name?.should be_true

      lexer = Lexer.new("世界")
      lexer.match_name?.should be_true

      lexer = Lexer.new("900")
      lexer.match_name?.should be_true

      lexer = Lexer.new("900-")
      lexer.match_name?.should be_true

      lexer = Lexer.new("NOT-A-NAME")
      lexer.match_name?.should be_false
    end
  end
end
