module CssParser
  class Token
    enum Kind
      IDENT
      EOF
    end

    @type : Kind
    @value : String | Nil

    def initialize
      @type = Kind::EOF
      @value = nil
    end
  end
end
