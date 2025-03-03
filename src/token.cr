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
      CLOSING_SQUARE_BRACKET
      COMMENT
      FUNCTION
      INCLUDES
      DASHMATCH
      DELIM
      EOF
      UNKNOWN
    end

    property type : Kind
    property value : String | Nil

    def initialize
      @type = Kind::UNKNOWN
      @value = nil
    end

    def preserved?
      if @type != Kind::FUNCTION && @type != Kind::CURLY_BRACKET && \
          @type != Kind::PARENTHESIS && @type != Kind::SQUARE_BRACKET
        return true
      else
        return false
      end
    end
  end
end
