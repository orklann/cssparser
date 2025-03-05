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
    # value for componet_value array
    property value : Array(ComponentValueNode)

    def initialize(@value)
    end
  end

  class ParenthesisBlockNode < ASTNode
    # value for componet_value array
    property value : Array(ComponentValueNode)

    def initialize(@value)
    end
  end

  class SquareBlockNode < ASTNode
    # value for componet_value array
    property value : Array(ComponentValueNode)

    def initialize(@value)
    end
  end

  class FunctionBlockNode < ASTNode
    # value for componet_value array
    property value : Array(ComponentValueNode)
    property ident : Token

    def initialize(@ident, @value)
    end
  end

  class ImportantNode < ASTNode
    def initialize
    end
  end
end

