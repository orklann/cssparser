require "./token"

module CssParser
  abstract class ASTNode

  end

  class DeclarationNode < ASTNode
    property ident_token : Token
    property componet_value : Token

    def initialize(@ident_token, @componet_value)
    end
  end

  class ComponentValueNode < ASTNode
    property value : Token

    def initialize(@value)
    end
  end
end

