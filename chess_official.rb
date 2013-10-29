require './pieces.rb'


class Game

  def initialize
    @board = Board.new
    @player1 = HumanPlayer.new("white")
    @player2 = HumanPlayer.new("black")
  end

  def play
    players = [@player1, @player2]
    turn = 0
    until @board.checkmate?(players[turn%2].color)
      #display board
      @board.pretty_print
      start_end_positions = players[turn%2].play_turn
      if (@board.board[start_end_positions[0][0]][start_end_positions[0][1]].class.superclass.superclass == Pieces)
        if (@board.board[start_end_positions[0][0]][start_end_positions[0][1]].color != players[turn%2].color)
          next
        end
      end
      #verify stuff maybe?
      #make sure that player1 can't move black pieces, vice versa
      begin
        @board.move(start_end_positions[0], start_end_positions[1])
      rescue StandardError => e
        puts e.message
        next
      end
      #handle errors maybe?
      turn += 1
    end
    @board.pretty_print
    puts "#{players[(turn+1)%2].color} wins!"
  end


end

class Board
  attr_accessor :board
  def initialize
    @board = make_board
    set_pieces_boards
  end

  def set_pieces_boards
    self.board.each do |row|
      row.each do |col|
        col.board_obj = self if col.class.superclass.superclass == Pieces
      end
    end
  end

  def checked?(color) #return true or false
    king_position = []
    self.board.each_index do |row|
      self.board[row].each_index do |column|
        king_position = [row,column] if self.board[row][column].class == King && self.board[row][column].color == color
      end
    end
    #king_position
    checked = false
    self.board.each_index do |row|
      self.board[row].each_index do |col|
        #is it a piece of the opposite color
        unless (self.board[row][col].nil?)
          if (self.board[row][col].color != color)#opposite color
            checked = true if board[row][col].moves(self.board).include?(king_position)
          end
        end
        #check its .moves
        #checked = true if its moves.include?(king_position)

      end
    end

    checked
  end

  def dup
    b = Board.new
    b.board = self.board.map do |row|
      row.map do |col|
        if (col.class.superclass.superclass == Pieces)
          col.class.new(col.position.dup,col.color.dup,col.symbol.dup)
        else
          nil
        end
      end
    end#duplicate
    b #return the board object
  end

  def make_board
    board = Array.new(8) { Array.new(8) }
    board.each_index do |row|
      next if [2,3,4,5].include?(row)
      board[row].each_index do |column|
        if (row == 0 || row == 1)
          color = "white"
        else
          color = "black"
        end

        if (row == 0 || row == 7)
          if (column == 0 || column == 7)
            #rook
            board[row][column] = Rook.new([row,column],color,"R")
          elsif (column == 1 || column == 6)
            #knight
            board[row][column] = Knight.new([row,column],color,"N")
          elsif (column == 2 || column == 5)
            #bishop
            board[row][column] = Bishop.new([row,column],color,"B")
          elsif (column == 4)
            #queen
            board[row][column] = Queen.new([row,column],color,"Q")
          elsif (column == 3)
            #king
            board[row][column] = King.new([row,column],color,"K")
          end
        else
          #all pawns
          board[row][column] = Pawn.new([row,column],color,"P")
        end
      end
    end
    #board[2][2] = Pawn.new([2,2],"black","P")#black pawn at 2,2
    #board[3][3] = Queen.new([3,3],"black","Q")#black pawn at 2,2
    #board[5][2] = Knight.new([5,2],"white","N")#white knight at 5,2
    #board[5][4] = Knight.new([5,4],"white","N")#white knight at 5,4

    board
  end

  def move(start_pos, end_pos)
    #is there a piece at start_pos
    if (self.board[start_pos[0]][start_pos[1]].class.superclass.superclass != Pieces)
      raise "no piece at the starting position!"
    elsif (!self.board[start_pos[0]][start_pos[1]].moves(self.board).include?(end_pos))
      raise "that piece cannot move to that end position!"
    elsif (!self.board[start_pos[0]][start_pos[1]].valid_moves.include?(end_pos))
        raise "you will be in check!"
    else
      board[start_pos[0]][start_pos[1]].position = end_pos
      board[end_pos[0]][end_pos[1]] = board[start_pos[0]][start_pos[1]].dup
      board[end_pos[0]][end_pos[1]].has_moved = true
      board[start_pos[0]][start_pos[1]] = nil
      #move!!
    end


  end

  def move!(start_pos, end_pos)
    #is there a piece at start_pos
    if (self.board[start_pos[0]][start_pos[1]].class.superclass.superclass != Pieces)
      raise "no piece at the starting position!"
    elsif (!self.board[start_pos[0]][start_pos[1]].moves(self.board).include?(end_pos))
      raise "that piece cannot move to that end position!"
    else
      self.board[start_pos[0]][start_pos[1]].position = end_pos
      self.board[end_pos[0]][end_pos[1]] = self.board[start_pos[0]][start_pos[1]].dup
      self.board[start_pos[0]][start_pos[1]] = nil
      #move!!
    end


  end

  def checkmate?(color)
    return false unless self.checked?(color)
    checkmate = true
    self.board.each_index do |row|
      self.board[row].each_index do |col|
        if (self.board[row][col].class.superclass.superclass == Pieces)
          if (self.board[row][col].color == color)
            checkmate = false if self.board[row][col].valid_moves.length > 0
          end
        end
      end
    end

    checkmate
  end


  def pretty_print
    #self.board[row][column].symbol
    self.board.each do |row|
      row_arr = row.map do |column|
        if column.class.superclass.superclass == Pieces
          column.symbol
        else
          " "
        end
      end

      p row_arr
    end
    p "-------------------------"
    p ("a".."h").to_a.reverse
    return nil
  end

end

class Array

  def dd_inject
    inject([]) { |dup, el| dup << (el.is_a?(Array) ? el.dd_inject : el) }
  end

end

class HumanPlayer
  attr_accessor :color
  def initialize(color)
    @color = color
  end

  def valid?(input)
    return false unless input[0] =~ /[a-h]/
    return false unless input[1] =~ /[1-8]/
    return false unless input[2] == " "
    return false unless input[3] =~ /[a-h]/
    return false unless input[4] =~ /[1-8]/
    true
  end

  def play_turn
    #e2 e4
    puts "enter valid move eg 'e2 e4' you are #{self.color}"
    input = gets.chomp
    until valid?(input)
      puts "invalid entry, make sure format is like: e2 e4"
      input = gets.chomp
    end
    #validate this!
    arr = input.split(" ")
    start_pos = arr[0].split("")
    start_pos[0] = 7 - (start_pos[0].ord - "a".ord)
    start_pos[1] = start_pos[1].to_i - 1
    start_pos[1],start_pos[0] = start_pos

    #letter is col
    end_pos = arr[1].split("")
    end_pos[0] = 7 - (end_pos[0].ord - "a".ord)
    end_pos[1] = end_pos[1].to_i - 1
    end_pos[1],end_pos[0] = end_pos

    [start_pos,end_pos]
  end

end
