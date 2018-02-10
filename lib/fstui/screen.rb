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
end 
