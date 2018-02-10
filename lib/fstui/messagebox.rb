module FSTui
  class MessageBox
    attr_accessor :title
    def initialize(screen, title, subtitle)
      @title = title
      @subtitle = subtitle
      @screen = screen
    end
    
    def show
      @win = Window.new(5, stdscr.maxx, stdscr.maxy / 2 - 3, 0)
      @win.addstr @title.center(@win.maxx)
      @win.addstr @subtitle.center(@win.maxx) + "\n"
      @win.refresh
      @screen.redraw
      @screen.inputbar.hide
    end
    
    def hide
      @win.clear
      @win.refresh
      @win.close
      @screen.redraw
    end
  end
end
