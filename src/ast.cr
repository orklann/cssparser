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
    property value : Token | CurlyBlockNode | ParenthesisBlockNode \
                     | SquareBlockNode | FunctionBlockNode

    def initialize(@value)
    end
  end

  class CurlyBlockNode < ASTNode
    property value : Array(ComponentValueNode)

    def initialize(@value)
    end
  end

  class ParenthesisBlockNode < ASTNode
    property value : Array(ComponentValueNode)

    def initialize(@value)
    end
  end

  class SquareBlockNode < ASTNode
    property value : Array(ComponentValueNode)

    def initialize(@value)
    end
  end

  class FunctionBlockNode < ASTNode
    property value : Array(ComponentValueNode)

    def initialize(@value)
    end
  end
end

