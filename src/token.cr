module CssParser
  class Token
    enum Kind
      IDENT
      ATKEYWORD
      STRING
      HASH
      NUM
      PERCENTAGE
      DIMENSION
      URI
      UNICODE_RANGE
      CDO
      CDC
      S
      COLON
      SEMICOLON
      CURLY_BRACKET
      CLOSING_CURLY_BRACKET
      PARENTHESIS
      CLOSING_PARENTHESIS
      SQUARE_BRACKET
      EOF
      UNKNOWN
    end

    property type : Kind
    property value : String | Nil

    def initialize
      @type = Kind::UNKNOWN
      @value = nil
    end
  end
end
