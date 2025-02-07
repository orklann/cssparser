require "./token.cr"

module CssParser
  class Lexer
    @token : Token
    @reader : Char::Reader

    def initialize(string : String)
      @token = Token.new
      @reader = Char::Reader.new(string)
    end

    # Match macro nmstart
    def match_nmstart

    end

    # Match macro nonascii
    def match_nonascii

    end

    # Match macro escape
    def match_escape

    end

    def match_unicode
      char = current_char
      if char == '\\'
        char = next_char
        char_count = 1
        while true
          if char_count > 6
            break
          end
          if (char >= '0' && char <= '9') || (char >= 'a' && char <= 'f')
            char = next_char
            char_count += 1
          else
            if char_count == 1
              raise "match unicode macro failed"
            end
            break
          end
        end
        if char == '\r'
          char = next_char
          if char == '\n'
            next_char
          end
        elsif space?(char)
          next_char
        end
      else
        raise "match unicode macro failed"
      end
    end

    def space?(char : Char)
      if char.in?(" \n\r\t\f")
        return true
      else
        return false
      end
    end
    def next_token

    end

    def current_char
      @reader.current_char
    end

    def next_char
      @reader.next_char
    end

    def current_pos
      @reader.pos
    end

    def string_range(start_pos, end_pos)
      @reader.string.byte_slice(start_pos, end_pos - start_pos)
    end

    def string_range(start_pos)
      string_range(start_pos, current_pos)
    end
  end
end
