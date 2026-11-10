module FSTui
  class DataScreen
    attr_accessor :title, :subtitle, :data

    def initialize(screen, title, subtitle, data)
      @screen = screen
      @title = title
      @subtitle = subtitle
      @data = data
    end
    
    def get_response(options: nil, timeout: nil)
      loop do
        @win = Window.new(stdscr.maxy-4, stdscr.maxx, 5, 0)
        @win.addstr @title.center(@win.maxx)
        @win.addstr @subtitle.center(@win.maxx) + "\n"
      
        # figure out which line is the longest and center it
        longest_line = 0
        @data.each_line do |line|
          longest_line = line.length if line.length > longest_line
        end
        padding = " " * (@win.maxx / 2 - longest_line / 2)
      
        # draw the data block, with the longest line centered and all others left justified with it
        @data.each_line do |line|
          @win.addstr "#{padding}#{line.strip}\n"
        end

        @win.noutrefresh
        selection = @screen.inputbar.get_selection(options: options, timeout: timeout)
        @win.clear
        @win.noutrefresh
        @win.close
        return selection
      end
    end
  end
end
