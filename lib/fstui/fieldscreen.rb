module FSTui
  class FieldScreen
    attr_accessor :title, :subtitle, :fields

    def initialize(screen, title, subtitle, fields)
      @screen = screen
      @title = title
      @subtitle = subtitle
      @fields = fields
    end
    
    def get_response(options: nil)
      loop do
        # TODO: window length needs to be done better
        @win = Window.new(@fields.length*2+3, stdscr.maxx, 5, 0)
        @win.addstr @title.center(@win.maxx)
        @win.addstr @subtitle.center(@win.maxx) + "\n"
      
        # draw the fields on the form
        @fields.each_index do |idx|
          field = @fields[idx]
          @win.addstr "  #{idx+1} - #{field.display_name}: "
          @win.attron Curses::A_UNDERLINE
          @win.addstr "#{field.value}"
          @win.attroff Curses::A_UNDERLINE
          @win.addstr "\n\n"
        end
        
        @screen.inputbar.instructions = "#=Enter Data  ENTER=Submit Form"
        @win.refresh
        @screen.redraw
        selection = @screen.inputbar.get_selection(options: options)
        case selection
          when "1", "2", "3", "4", "5", "6", "7", "8", "9"
            edit_field selection.to_i-1
          when :enter
            # check that all required fields have data
            field_errors = 0
            @fields.each_index do |idx|
              field = @fields[idx]
              next unless field.is_required?
              next unless field.value == "" or field.value == nil
              field_row = 3+idx*2

              @win.setpos field_row, 0
              @win.addstr "  #{idx+1} X #{field.display_name}: "
              @win.standout
              @win.addstr "                                 "
              @win.clrtoeol
              @win.setpos field_row, 8+field.display_name.length
              field_errors += 1
            end
            
            if(field_errors == 0) then
              # everything looks good, end here and return the collected data
              @win.clear
              @win.refresh
              @win.close
              return @fields
            else
              @screen.inputbar.instructions = "Missing data in required field!"
              @win.refresh
              @screen.redraw
              sleep 1
            end
        end
      end
    end

    def edit_field(field_nbr)
      field = @fields[field_nbr]
      field_row = 3+field_nbr*2
      @win.setpos field_row, 0
      @win.addstr "  #{field_nbr+1} - #{field.display_name}: "
      @win.standout
      @win.addstr "                                 "
      @win.clrtoeol
      @win.setpos field_row, 8+field.display_name.length
      noecho
      @win.refresh
      @win.keypad(true)
      value = ""
      insert_pos = 0
      loop do
        char = @win.getch
        case char
          when 10, 13, "\n", "\r"
            break
          when 8, KEY_BACKSPACE, "\b"
            row = @win.cury
            col = @win.curx
            value = value[0..insert_pos-2] + value[insert_pos..-1]
            insert_pos -= 1
            @win.setpos(row, col-1)
            @win.addstr value[insert_pos..-1] + ' '
            @win.setpos(row, col-1)
          when KEY_LEFT
            next unless insert_pos > 0
            row = @win.cury
            col = @win.curx
            @win.setpos(row, col-1)
            insert_pos -= 1
          when KEY_RIGHT
            next unless insert_pos < value.length
            row = @win.cury
            col = @win.curx
            @win.setpos(row, col+1)
            insert_pos += 1
          when KEY_DOWN, KEY_UP
          else
            #@screen.destroy
            #pp char
            #Kernel.exit
            value.insert(insert_pos, char)
            insert_pos += 1
            if(insert_pos == value.length) then
              # adding chars at the end, easy
              @win.addch char
            else
              # adding chars in the middle, need to redraw the rest of the field
              row = @win.cury
              col = @win.curx
              @win.addstr value[insert_pos-1..-1]
              @win.setpos(row, col+1)
            end
        end
      end
      @win.keypad(false)
      echo
      @win.standend

      @fields[field_nbr].value = value
    end
  end

  class Field
    attr_accessor :name, :required, :value
    def initialize(name:, required: true)
      @name = name
      @required = required
    end

    def display_name
      disp_name = @name
      disp_name += " (opt)" unless @required
      disp_name
    end
    
    def is_required?
      @required
    end
  end
end
