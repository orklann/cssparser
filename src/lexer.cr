require "./token.cr"

module CssParser
  class Lexer
    @token : Token
    @reader : Char::Reader

    def initialize(string : String)
      @token = Token.new
      @reader = Char::Reader.new(string)
    end

    def match_nmchar
      char = current_char
      if char == '_' || (char >= 'a' && char <= 'z') || \
          (char >= '0' && char <= '9') || char == '-'
        next_char
        return
      end
      start_pos = current_pos
      begin
        match_nonascii
      rescue
        set_current_pos(start_pos)
        begin
          match_escape
        rescue
          raise "match nmchar macro failed"
        end
      end
    end


    def match_nmstart
      char = current_char
      if char == '_' || (char >= 'a' && char <= 'z')
        next_char
      else
        start_pos = current_pos
        begin
          match_nonascii
        rescue
          set_current_pos(start_pos)
          begin
            match_escape
          rescue
            raise "match nmstart macro failed"
          end
        end
      end
    end

    def match_nonascii
      char = current_char
      if !char.ord.in?(0..0x9f)
        next_char
      else
        raise "match nonascii macro failed"
      end
    end

    def match_escape
      start_pos = current_pos
      begin
        match_unicode
      rescue
        set_current_pos(start_pos)
        char = current_char
        if char == '\\'
          char = next_char
          if !char.in?("\n\r\f0123456789abcdef")
            next_char
          end
        else
          raise "match escape macro failed"
        end
      end
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

    def set_current_pos(pos)
      @reader.pos = pos
    end

    def string_range(start_pos, end_pos)
      @reader.string.byte_slice(start_pos, end_pos - start_pos)
    end

    def string_range(start_pos)
      string_range(start_pos, current_pos)
    end
  end
end
