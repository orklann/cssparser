require "./token.cr"

module CssParser
  class Lexer
    @token : Token
    @reader : Char::Reader

    def initialize(string : String)
      @token = Token.new
      @reader = Char::Reader.new(string)
    end

    def match_num?
      char = current_char
      if char >= '0' && char <= '9'
        char = next_char
        can_process_period = true
        get_period = false
        while true
          if char >= '0' && char <= '9'
            char = next_char
            if get_period
              get_period = false
            end
          elsif char == '.' && can_process_period
            char = next_char
            can_process_period = false
            get_period = true
          else
            if get_period
              return false
            end
            break
          end
        end
        return true
      else
        return false
      end
    end

    def match_name?
      if match_nmchar?
        while match_nmchar?
          match_nmchar?
        end
        return true
      end
      return false
    end

    def match_nmchar?
      char = current_char
      if char == '_' || (char >= 'a' && char <= 'z') || \
          (char >= '0' && char <= '9') || char == '-'
        next_char
        return true
      end
      start_pos = current_pos
      if match_nonascii?
        return true
      else
        set_current_pos(start_pos)
        if match_escape?
          return true
        else
          return false
        end
      end
    end

    def match_nmstart?
      char = current_char
      if char == '_' || (char >= 'a' && char <= 'z')
        next_char
        return true
      else
        start_pos = current_pos
        if match_nonascii?
          return true
        else
          set_current_pos(start_pos)
          if match_escape?
            return true
          else
            return false
          end
        end
      end
    end

    def match_nonascii?
      char = current_char
      if !char.ord.in?(0..0x9f)
        next_char
        return true
      else
        return false
      end
    end

    def match_escape?
      start_pos = current_pos
      if match_unicode?
        return true
      else
        set_current_pos(start_pos)
        char = current_char
        if char == '\\'
          char = next_char
          if !char.in?("\n\r\f0123456789abcdef")
            next_char
            return true
          end
        else
          return false
        end
      end
    end

    def match_unicode?
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
              return false
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
        true
      else
        false
      end
    end

    def space?(char : Char)
      if char.in?(" \n\r\t\f")
        return true
      else
        return false
      end
    end

    def match_string?
      start_pos = current_pos
      if match_string_single?
        return true
      else
        set_current_pos(start_pos)
        if match_string_double?
          return true
        end
      end
      return false
    end

    def match_string_double?
      char = current_char
      if char == '"'
        char = next_char
        while true
          if char == '"' || char == '\0'
            break
          end
          if char == '\\'
            char = next_char
            if match_nl?
                char = next_char
            end
          elsif !char.in?("\n\r\f\"") || match_escape?
              char = next_char
          else
            return false
          end
        end
        return true
      else
        return false
      end
    end

    def match_string_single?
      char = current_char
      if char == '\''
        char = next_char
        while true
          if char == '\'' || char == '\0'
            break
          end
          if char == '\\'
            char = next_char
            if match_nl?
              char = next_char
            end
          elsif !char.in?("\n\r\f\"") || match_escape?
              char = next_char
          else
            return false
          end
        end
        return true
      else
        return false
      end
    end

    def match_nl?
      char = current_char
      if char == '\n' || char == '\f'
        return true
      elsif char == '\r'
        if peek_next_char == '\n'
          next_char
        end
        return true
      end
      return false
    end

    def scan_dimesion
      if match_num?
        scan_ident
        if @token.type == Token::Kind::IDENT
          @token.type = :DIMENSION
        end
      end
    end

    def scan_percentage
      if match_num?
        char = current_char
        if char == '%'
          next_char
          @token.type = :PERCENTAGE
        end
      end
    end

    def scan_num
      if match_num?
        @token.type = :NUM
      end
    end

    def scan_hash
      char = current_char
      if char == '#'
        next_char
        if match_name?
          @token.type = :HASH
        end
      end
    end

    def scan_string
      char = current_char
      if char == '"'
        match_string_double?
      elsif char == '\''
        match_string_single?
      end
      @token.type = :STRING
    end

    def scan_ident
      char = current_char
      if char == '-'
        next_char
      end

      if match_nmstart?
        while current_char != '\0'
          match_nmchar?
        end
        @token.type = :IDENT
      end
    end

    def scan_at_keyword
      char = current_char
      if char == '@'
        next_char
      end
      scan_ident
      @token.type = :ATKEYWORD
    end

    def next_token
      reset_token
      start_pos = current_pos
      char = current_char

      case char
      when '-'
        scan_ident
        @token.value = string_range(start_pos)
      when '@'
        scan_at_keyword
        @token.value = string_range(start_pos)
      when '\''
        scan_string
        @token.value = string_range(start_pos)
      when '"'
        scan_string
        @token.value = string_range(start_pos)
      when '#'
        scan_hash
        @token.value = string_range(start_pos)
      when '0'
      when '1'
      when '2'
      when '3'
      when '4'
      when '5'
      when '6'
      when '7'
      when '8'
      when '9'
        scan_dimesion
        if @token.type != Token::Kind::DIMENSION
          set_current_pos(start_pos)
          scan_percentage
          if @token.type != Token::Kind::PERCENTAGE
            set_current_pos(start_pos)
            scan_num
          end
        end
        @token.value = string_range(start_pos)
      end
      @token
    end

    def current_char
      @reader.current_char
    end

    def next_char
      @reader.next_char
    end

    def peek_next_char
      @reader.peek_next_char
    end

    def current_pos
      @reader.pos
    end

    def reset_token
      @token.type = :UNKNOWN
      @token.value = nil
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
