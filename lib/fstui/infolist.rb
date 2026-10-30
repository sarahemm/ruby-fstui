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

    def <<(item)
      @items.push item
    end

    def clear_items
      @items = []
    end

    def get_response(extra_options: [])
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
          # figure out which line has the longest right-hand side so we know how much to trim the left so it doesn't interfere
          longest_rhs = 0
          item.rows.each do |row|
            longest_rhs = row.rhs.length if row.rhs.length > longest_rhs
          end
          lhs = truncate(item.rows[0].lhs, stdscr.maxx - 6 - longest_rhs - 3)
          @win.addstr "  #{idx}. #{lhs}" + " "*(stdscr.maxx - 5 - 1 - idx.to_s.length - lhs.length - item.rows[0].rhs.length) + "#{item.rows[0].rhs}\n"
          if(item.rows.length > 1)
            item.rows[1..-1].each do |row|
              lhs = truncate(row.lhs, stdscr.maxx - 9 - longest_rhs - 3)
              @win.addstr "       #{lhs}" + " "*(stdscr.maxx - 7 - 2 - lhs.length - row.rhs.length) + "#{row.rhs}\n"
            end
          end
          @win.addstr "\n"
          idx += 1
        end
        morepages = page < total_pages ? "More on Next Screen" : "End of List"
        @win.addstr "\n** #{@items.length} Items UNSORTED - Page #{page} of #{total_pages} - #{morepages} **"

        @win.noutrefresh
        old_instructions = @screen.inputbar.instructions
        instructions = []
        extra_options.each do |key, desc|
          instructions << "#{key}=#{desc}"
        end
        instructions.push "B=Back" if page > 1
        instructions.push "<Enter>=Next Screen" if page < total_pages
        @screen.inputbar.instructions = instructions.join(", ")
        selection = @screen.inputbar.get_string
        @screen.inputbar.instructions = old_instructions
        @win.clear
        @win.noutrefresh
        @win.close
        
        if(selection == "" and page < total_pages)
          page += 1
        elsif(selection == "b" or selection == "B" and page > 1)
          page -= 1
        elsif(extra_options.keys.include?(selection.upcase) or extra_options.keys.include?(selection.downcase))
          return selection
        else
	  return @items[selection.to_i - 1].key if selection.to_i > 0 and selection.to_i < @items.length + 1
        end
      end
    end

    private

    def truncate(str, len)
      return str if str.length <= len
      "#{str[0..len-3]}..."
    end

  end
  class InfoItem
    attr_accessor :key, :rows

    def initialize(key:, rows:)
      @key = key
      @rows = rows
    end
  end

  class InfoRow
    attr_accessor :lhs, :rhs

    def initialize(lhs:, rhs:)
      @lhs = lhs
      @rhs = rhs
    end

    def [](idx)
      return @lhs if idx == 0
      return @rhs if idx == 1

      nil
    end
  end
end
