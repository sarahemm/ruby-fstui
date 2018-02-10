require "curses";
include Curses

module FSTui
  class Screen
    attr_accessor :titlebar, :inputbar
    
    def initialize
      init_screen
      start_color
      crmode
      
      @titlebar = TitleBar.new(self)
      @inputbar = InputBar.new(self)
    end
    
    def destroy
      close_screen
    end
    
    def redraw
      @titlebar.redraw
      @inputbar.redraw
    end
    
    def new_menu(title, subtitle = "Please select one of the options below.")
      Menu.new(self, title, subtitle)
    end

    def new_inputbox(title, subtitle = "Please enter your selection below.")
      InputBox.new(self, title, subtitle)
    end
  end

  class TitleBar
    attr_accessor :left, :center, :right
    
    def initialize(screen, pad_chars = 2)
      @win = Window.new(1, stdscr.maxx, 0, 0)
      @win.attrset A_REVERSE
      @win.refresh
      @left = @center = @right = ""
      @pad_chars = pad_chars
      redraw
    end
    
    def redraw
      @win.clear
      @win.addstr (" " * @pad_chars) + @left + @center.center(@win.maxx - (@left.length + @pad_chars) - (@right.length + @pad_chars)) + @right + (" " * @pad_chars)
      @win.refresh
    end
  end
  
  class InputBar
    attr_accessor :prompt
    
    def initialize(screen, prompt = " Enter your selection(s) and press <Enter> : ")
      @prompt = prompt
      window_setup
    end

    def window_setup
      @promptwin = Window.new(1, @prompt.length, stdscr.maxy - 2, 0)
      @promptwin.attrset A_REVERSE
      @entrywin = Window.new(1, stdscr.maxx - @prompt.length, stdscr.maxy - 2, @prompt.length + 1)
      refresh
    end
    
    def prompt=(prompt)
      @prompt = prompt
      destroy
      window_setup
    end

    def destroy
      @promptwin.close_screen
      @entrywin.close_screen
    end
    
    def redraw
      @promptwin.clear
      @promptwin.addstr @prompt
      @promptwin.refresh
    end
    
    def get_selection
      @entrywin.setpos 0, 0
      entry = @entrywin.getch
      @entrywin.clear
      @entrywin.refresh
      entry
    end
    
    def get_string
      @entrywin.setpos 0, 0
      entry = @entrywin.getstr
      @entrywin.clear
      @entrywin.refresh
      entry
    end
  end
  
  class Menu
    attr_accessor :title
    def initialize(screen, title, subtitle)
      @title = title
      @subtitle = subtitle
      @items = Array.new
      @screen = screen
    end
    
    def add_item(key, desc)
      @items.push MenuItem.new(key, desc)
    end
    
    def get_response
      loop do
        @win = Window.new(@items.length + 4, stdscr.maxx, 5, 0)
        @win.addstr @title.center(@win.maxx)
        @win.addstr @subtitle.center(@win.maxx) + "\n"
      
        # figure out which item is the longest and center it
        longest_item = 0
        @items.each do |item|
          longest_item = item.desc.length if item.desc.length > longest_item
        end
        padding = " " * (@win.maxx / 2 - longest_item / 2)
      
        # draw the menu, with the longest item centered and all others left justified with it
        @items.each_index do |idx| 
          menu_text = "#{padding}#{idx + 1}. #{@items[idx].desc}\n"
          @win.addstr menu_text
        end

        @win.refresh
        @screen.redraw
        selection = @screen.inputbar.get_selection
        @win.clear
        @win.refresh
        @win.close
        return @items[selection.to_i - 1].key if(("0".."9").include?(selection) and selection.to_i <= @items.length)
      end
    end
    
    class MenuItem
      attr_accessor :key, :desc
      
      def initialize(key, desc)
        @key = key
        @desc = desc
      end
    end
  end
  
  class InputBox
    attr_accessor :title
    def initialize(screen, title, subtitle)
      @title = title
      @subtitle = subtitle
      @items = Array.new
      @screen = screen
    end
    
    def get_entry
      @win = Window.new(5, stdscr.maxx, stdscr.maxy / 2 - 3, 0)
      @win.addstr @title.center(@win.maxx)
      @win.addstr @subtitle.center(@win.maxx) + "\n"
      
      @win.refresh
      @screen.redraw
      selection = @screen.inputbar.get_string
      @win.close
      selection
    end
  end
end
