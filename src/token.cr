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
