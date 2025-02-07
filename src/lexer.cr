require "./token.cr"

module CssParser
  class Lexer
    @token : Token
    @reader : Char::Reader

    def initialize(string : String)
      @token = Token.new
      @reader = Char::Reader.new(string)
    end

    def next_token

    end

    def current_char
      @reader.current_char
    end

    def next_char
      @reader.next_char
    end
  end
end
