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
end

