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

    def match_w
      char = current_char
      while space?(char)
        char = next_char
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

    def scan_comment
      char = current_char
      if char == '/' && next_char == '*'
        char = next_char
        while char != '*'
          char = next_char
        end
        # Here we are sure char is matched to '*' already
        char = next_char
        while char == '*'
          char = next_char
        end

        while !char.in?("/*")
          char = next_char
          while char != '*'
            char = next_char
          end
          char = next_char
          while char == '*'
            char = next_char
          end
        end
        if char == '/'
          next_char
          @token.type = :COMMENT
        end
      end
    end

    def scan_s
      char = current_char
      if char.in?(" \t\r\n\f")
        char = next_char
        while true
          if char.in?(" \t\r\n\f")
            char = next_char
          else
            break
          end
        end
        @token.type = :S
      end
    end

    def scan_cdo
      char = current_char
      if char == '<' && next_char == '!' && next_char == '-' && next_char == '-'
        next_char
        @token.type = :CDO
      end
    end

    def scan_cdc
      char = current_char
      if char == '-' && next_char == '-' && next_char == '>'
        next_char
        @token.type = :CDC
      end
    end

    def scan_unicode_range
      char = current_char
      if char == 'u' && next_char == '+'
        char_count = 1
        char = next_char
        while true
          if char_count > 6
            break
          end
          if (char >= '0' && char <= '9') || (char >= 'a' && char <= 'f') \
              || char == '?'
            char = next_char
          else
            break
          end
        end
        if char == '-'
          char = next_char
          char_count = 1
          while true
            if char_count > 6
              break
            end
            if (char >= '0' && char <= '9') || (char >= 'a' && char <= 'f')
              char = next_char
            else
              break
            end
          end
        end
        @token.type = :UNICODE_RANGE
      end
    end

    def scan_uri
      char = current_char
      if char == 'u' && next_char == 'r' && next_char == 'l' && next_char == '('
        next_char
        match_w
        start_pos = current_pos
        if match_string?
          match_w
        else
          set_current_pos(start_pos)
          char = current_char
          if char != ')'
            while true
              if !char.in?("#$%&*-\[\]-~")
                char = next_char
              elsif match_nonascii? || match_escape?
                char = current_char
              else
                break
              end
            end
          else
            next_char
            @token.type = :URI
            return
          end
        end
        match_w
        if next_char == ')'
          next_char
          @token.type = :URI
        end
      end
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
          if !match_nmchar?
            break
          end
        end
        @token.type = :IDENT
      end
    end

    def scan_function
      char = current_char
      if char == '-'
        next_char
      end

      if match_nmstart?
        while current_char != '\0'
          if !match_nmchar?
            break
          end
        end
        char = current_char
        if char == '('
          next_char
          @token.type = :FUNCTION
        end
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

      scan_s
      if @token.type != Token::Kind::S
        set_current_pos(start_pos)
      else
        @token.value = string_range(start_pos)
        return @token
      end

      if char == 'u' && next_char == 'r' && next_char == 'l'
        set_current_pos(start_pos)
        scan_uri
      end

      if @token.type != Token::Kind::URI
        set_current_pos(start_pos)
      else
        @token.value = string_range(start_pos)
        return @token
      end

      char = current_char
      start_pos = current_pos

      if char == 'u' && peek_next_char == '+'
        set_current_pos(start_pos)
        scan_unicode_range
      end

      if @token.type != Token::Kind::UNICODE_RANGE
        set_current_pos(start_pos)
      else
        @token.value = string_range(start_pos)
        return @token
      end

      scan_function

      if @token.type != Token::Kind::FUNCTION
        set_current_pos(start_pos)
      else
        @token.value = string_range(start_pos)
        return @token
      end

      if match_nmstart?
        scan_ident
        @token.value = string_range(start_pos)
        return @token
      end

      set_current_pos(start_pos)
      char = current_char

      case char
      when '-'
        start_pos = current_pos
        scan_ident
        if @token.type != Token::Kind::IDENT
          set_current_pos(start_pos)
          scan_cdc
        end
        @token.value = string_range(start_pos)
      when '@'
        scan_at_keyword
        @token.value = string_range(start_pos)
      when '\'' || '"'
        scan_string
        @token.value = string_range(start_pos)
      when '#'
        scan_hash
        @token.value = string_range(start_pos)
      when '0'..'9'
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
      when '<'
        scan_cdo
        @token.value = string_range(start_pos)
      when ':'
        next_char
        @token.type = :COLON
        @token.value = string_range(start_pos)
      when ';'
        next_char
        @token.type = :SEMICOLON
        @token.value = string_range(start_pos)
      when '{'
        next_char
        @token.type = :CURLY_BRACKET
        @token.value = string_range(start_pos)
      when '}'
        next_char
        @token.type = :CLOSING_CURLY_BRACKET
        @token.value = string_range(start_pos)
      when '('
        next_char
        @token.type = :PARENTHESIS
        @token.value = string_range(start_pos)
      when ')'
        next_char
        @token.type = :CLOSING_PARENTHESIS
        @token.value = string_range(start_pos)
      when '['
        next_char
        @token.type = :SQUARE_BRACKET
        @token.value = string_range(start_pos)
      when ']'
        next_char
        @token.type = :CLOSING_SQUARE_BRACKET
        @token.value = string_range(start_pos)
      when '/'
        set_current_pos(start_pos)
        scan_comment
        @token.value = string_range(start_pos)
      when '~'
        if next_char == '='
          next_char
          @token.type = :INCLUDES
          @token.value = string_range(start_pos)
        end
      when '|'
        if next_char == '='
          next_char
          @token.type = :DASHMATCH
          @token.value = string_range(start_pos)
        end
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
