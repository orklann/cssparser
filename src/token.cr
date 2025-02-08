module CssParser
  class Token
    enum Kind
      IDENT
      ATKEYWORD
      EOF
    end

    property type : Kind
    property value : String | Nil

    def initialize
      @type = Kind::EOF
      @value = nil
    end
  end
end
