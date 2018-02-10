module FSTui
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
