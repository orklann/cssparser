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

    it "match string_double" do
      lexer = Lexer.new("\"abc\"")
      lexer.match_string_double?.should be_true

      lexer = Lexer.new("\"ABC\"")
      lexer.match_string_double?.should be_true

      lexer = Lexer.new("\"ABC世界\"")
      lexer.match_string_double?.should be_true

      lexer = Lexer.new("\"\\\n\\\r\\\f\\\r\n\"")
      lexer.match_string_double?.should be_true

      lexer = Lexer.new("a\"")
      lexer.match_string_double?.should be_false
    end

    it "match string_single" do
      lexer = Lexer.new("'abc'")
      lexer.match_string_single?.should be_true

      lexer = Lexer.new("'ABC'")
      lexer.match_string_single?.should be_true

      lexer = Lexer.new("'ABC世界'")
      lexer.match_string_single?.should be_true

      lexer = Lexer.new("'\\\n\\\r\\\f\\\r\n'")
      lexer.match_string_single?.should be_true

      lexer = Lexer.new("a\"")
      lexer.match_string_single?.should be_false
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

    it "return HASH token" do
      lexer = Lexer.new("#_abc")
      token = lexer.next_token
      token.type.should eq(Token::Kind::HASH)
      token.value.should eq("#_abc")

      lexer = Lexer.new("#abc")
      token = lexer.next_token
      token.type.should eq(Token::Kind::HASH)
      token.value.should eq("#abc")

      lexer = Lexer.new("#世界")
      token = lexer.next_token
      token.type.should eq(Token::Kind::HASH)
      token.value.should eq("#世界")

      lexer = Lexer.new("#900")
      token = lexer.next_token
      token.type.should eq(Token::Kind::HASH)
      token.value.should eq("#900")

      lexer = Lexer.new("#900-")
      token = lexer.next_token
      token.type.should eq(Token::Kind::HASH)
      token.value.should eq("#900-")
    end

    it "match num" do
      lexer = Lexer.new("09090")
      lexer.match_num?.should be_true

      lexer = Lexer.new("111.0")
      lexer.match_num?.should be_true

      lexer = Lexer.new("a1000.0")
      lexer.match_num?.should be_false

      lexer = Lexer.new("1000.a")
      lexer.match_num?.should be_false

      lexer = Lexer.new("1000.")
      lexer.match_num?.should be_false

      lexer = Lexer.new("1000.00.")
      lexer.match_num?.should be_true
    end

    it "return NUM token" do
      lexer = Lexer.new("9999")
      token = lexer.next_token
      token.type.should eq(Token::Kind::NUM)
      token.value.should eq("9999")
    end

    it "return PERCENTAGE token" do
      lexer = Lexer.new("99%")
      token = lexer.next_token
      token.type.should eq(Token::Kind::PERCENTAGE)
      token.value.should eq("99%")
    end
  end
end
