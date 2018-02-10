module FSTui
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
end
