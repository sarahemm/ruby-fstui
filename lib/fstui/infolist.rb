module FSTui
  class InfoList
    attr_accessor :infoline, :left_heading, :right_heading

    def initialize(screen, infoline, lines_per_item)
      @infoline = infoline
      @lines_per_item = lines_per_item
      @items = Array.new
      @screen = screen
    end
    
    def add_item(item)
      @items.push item
    end
    
    def get_response
      page = 1
      loop do
        @win = Window.new(stdscr.maxy - 5, stdscr.maxx, 2, 0)
        @win.addstr @infoline
        @win.setpos 2, 0
        @win.attron A_REVERSE
        @win.addstr " "*5 + @left_heading + " " * (stdscr.maxx - 5 - 5 - @left_heading.length - @right_heading.length) + @right_heading + " "*5
        @win.attroff A_REVERSE
        
        items_per_page = (@win.maxy - 6) / (@lines_per_item + 1)
        total_pages = @items.length / items_per_page
        start_item = items_per_page * (page-1)

        idx = start_item + 1
	@items[start_item..start_item + items_per_page].each do |item|
          @win.addstr "  #{idx}. #{item[0][0]}" + " "*(stdscr.maxx - 5 - 1 - idx.to_s.length - item[0][0].length - item[0][1].length) + "#{item[0][1]}\n"
          if(item.length > 1)
            item[1..-1].each do |line|
              @win.addstr "       #{line[0]}" + " "*(stdscr.maxx - 7 - 2 - line[0].length - line[1].length) + "#{line[1]}\n"
            end
          end
          @win.addstr "\n"
          idx += 1
        end
        morepages = page < total_pages ? "More on Next Screen" : "End of List"
        @win.addstr "\n** #{@items.length} Items UNSORTED - Page #{page} of #{total_pages} - #{morepages} **"

        @win.refresh
        old_instructions = @screen.inputbar.instructions
        instructions = []
        instructions.push "B=Back" if page > 1
        instructions.push "<Enter>=Next Screen" if page < total_pages
        @screen.inputbar.instructions = instructions.join(", ")
        @screen.redraw
        selection = @screen.inputbar.get_string
        @screen.inputbar.instructions = old_instructions
        @win.clear
        @win.refresh
        @win.close
        
        if(selection == "" and page < total_pages)
          page += 1
        elsif(selection == "b" or selection == "B" and page > 1)
          page -= 1
        else
	  return selection.to_i - 1 if selection.to_i > 0 and selection.to_i < @items.length + 1
        end
      end
    end
  end
end
