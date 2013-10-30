require './pieces.rb'
require 'colorize'
require 'yaml'

class Game
  attr_accessor :board
  def initialize
    @board = Board.new
    @player1 = HumanPlayer.new("white")
    @player2 = HumanPlayer.new("black")
    @turn = 0
  end

  def color_equal?(pos,color)
    if (@board.board[pos[0][0]][pos[0][1]].class.superclass.superclass == Pieces)
      if (@board.board[pos[0][0]][pos[0][1]].color != color)
        return false
      end
    end
    true
  end

  def try_move

  end

  def play
    players = [@player1, @player2]
    turn = @turn
    until @board.game_over?(players[turn%2].color)
      #display board
      @board.pretty_print
      @board.all_boards << @board.track_board
      s_e_pos = players[turn%2].play_turn
      next unless color_equal?(s_e_pos,players[turn%2].color)
      begin
        @board.move(s_e_pos[0], s_e_pos[1])
      rescue StandardError => e
        puts e.message
        puts e.backtrace
        next
      end
      if @board.pawn_promoted?
        new_piece = players[turn%2].new_piece
        @board.replace_pawn(new_piece)
      end
      turn += 1
      @turn = turn
    end
    @board.pretty_print
    puts "#{players[(turn+1)%2].color} wins!"
  end

  def save_game
    serialized = self.to_yaml
    file = File.open('saved_chess.txt','w+')
    file.print serialized
    file.close
    puts "Game successfully saved!"
  end
end

class Board
  attr_accessor :board, :all_boards
  def initialize
    @board = make_board
    set_pieces_boards
    @all_boards = []
  end

  def set_pieces_boards
    self.board.each do |row|
      row.each do |col|
        col.board_obj = self if col.class.superclass.superclass == Pieces
      end
    end
  end

  def pawn_promoted?
    pawn_promoted = false
    self.board.each_with_index do |row, i|
      next unless i == 0 || i == 7
      row.each do |col|
        pawn_promoted = true if col.class == Pawn
      end
    end

    pawn_promoted
  end

  def replace_pawn(piece_sym)
    pos = []
    self.board.each_with_index do |row, i|
      next unless i == 0 || i == 7
      row.each_with_index do |col, j|
        pos = [i,j] if col.class == Pawn
      end
    end
    class_hash = {"B" => Bishop, "R" => Rook, "N" => Knight, "Q" => Queen }

    self.board[pos[0]][pos[1]] = class_hash[piece_sym].new(pos,board[pos[0]][pos[1]].color,piece_sym,self)
    self.board[pos[0]][pos[1]].board_obj = self
  end

  def track_board
    self.board.map do |row|
      row.map do |col|
        if col.class.superclass.superclass == Pieces
          col.symbol
        else
          nil
        end
      end
    end
  end

  def stalemate?(color)
    return false if self.checked?(color)
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

  def draw?(color)
    return true if three_repeat? #checks all boards so far and counts for >= 3 of the current one
    return true if checkmate_impossible?
    false
  end

  def checkmate_impossible?
    #if there's a rook or queen on the board checkmate is possible (return false)
    #
    false
  end

  def three_repeat?
    self.all_boards.count(self.track_board) >= 3
  end


  def game_over?(color)
    return true if self.checkmate?(color)
    return true if self.stalemate?(color)
    return true if self.draw?(color)
    false
  end

  def checked?(color) #return true or false
    king_position = get_king_position(color)
    checked = false
    self.board.each_index do |row|
      self.board[row].each_index do |col|
        if (opposite_color_piece?(row,col,color))
          checked = true if self.board[row][col].moves.include?(king_position)
        end
      end
    end

    checked
  end

  def opposite_color_piece?(row,col,color)
    #returns false if not a piece or same color
    if (self.board[row][col].class.superclass.superclass == Pieces)
      if (self.board[row][col].color != color)
        return true
      end
    end

    false
  end

  def get_king_position(color)
    king_position = []
    self.board.each_index do |row|
      self.board[row].each_index do |column|
        king_position = [row,column] if self.board[row][column].class == King && self.board[row][column].color == color
      end
    end

    king_position
  end

  def dup
    b = Board.new
    b.board = self.board.map do |row|
      row.map do |col|
        if (col.class.superclass.superclass == Pieces)
          col.class.new(col.position.dup,col.color.dup,col.symbol.dup,self)
        else
          nil
        end
      end
    end

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
        piece_maker(board,row,column,color)
      end
    end

    board
  end

  def piece_maker(board,row,column,color)
    if (row == 0 || row == 7)
      if (column == 0 || column == 7) #rook
        board[row][column] = Rook.new([row,column],color,"R",self)
      elsif (column == 1 || column == 6) #knight
        board[row][column] = Knight.new([row,column],color,"N",self)
      elsif (column == 2 || column == 5) #bishop
        board[row][column] = Bishop.new([row,column],color,"B",self)
      elsif (column == 4) #queen
        board[row][column] = Queen.new([row,column],color,"Q",self)
      elsif (column == 3) #king
        board[row][column] = King.new([row,column],color,"K",self)
      end
    else   #all pawns
      board[row][column] = Pawn.new([row,column],color,"P",self)
    end
  end

  def move(start_pos, end_pos)
    if (self.board[start_pos[0]][start_pos[1]].class.superclass.superclass != Pieces)
      raise "no piece at the starting position!"
    elsif (!self.board[start_pos[0]][start_pos[1]].moves.include?(end_pos))
      raise "that piece cannot move to that end position!"
    elsif (!self.board[start_pos[0]][start_pos[1]].valid_moves.include?(end_pos))
        raise "you will be in check!"
    else
      board[start_pos[0]][start_pos[1]].position = end_pos
      board[end_pos[0]][end_pos[1]] = board[start_pos[0]][start_pos[1]].dup
      board[end_pos[0]][end_pos[1]].has_moved = true
      board[start_pos[0]][start_pos[1]] = nil
    end
  end

  def move!(start_pos, end_pos)
    if (self.board[start_pos[0]][start_pos[1]].class.superclass.superclass != Pieces)
      raise "no piece at the starting position!"
    elsif (!self.board[start_pos[0]][start_pos[1]].moves.include?(end_pos))
      raise "that piece cannot move to that end position!"
    else
      self.board[start_pos[0]][start_pos[1]].position = end_pos
      self.board[end_pos[0]][end_pos[1]] = self.board[start_pos[0]][start_pos[1]].dup
      self.board[start_pos[0]][start_pos[1]] = nil
    end
  end

  def checkmate?(color)
    return false unless self.checked?(color)
    checkmate = true
    self.board.each_index do |row|
      self.board[row].each_index do |col|
        if same_color_piece?(row, col, color)
          checkmate = false if self.board[row][col].valid_moves.length > 0
        end
      end
    end

    checkmate
  end

  def same_color_piece?(row,col,color)
    if (self.board[row][col].class.superclass.superclass == Pieces)
      if (self.board[row][col].color == color)
        return true
      end
    end

    false
  end

  def pretty_print
    color_translate = { "white" => :red, "black" => :green }
    piece_translate = { "R" => ["\u2656","\u265c"],  "B" => ["\u2657","\u265d"],
       "K" => ["\u2654","\u265a"], "Q" => ["\u2655","\u265b"], "N" => ["\u2658","\u265e"],
       "P" => ["\u2659","\u265F"] }
    self.board.each_with_index do |row,i|
      print (i+1); print(' ')
      row_arr = row.each_with_index do |column,j|
        bg = color_translate.values[(j+i)%2]
        if column.class.superclass.superclass == Pieces
           color_index = color_translate.keys.index(column.color)
           print(" #{piece_translate[column.symbol][color_index]} ".colorize(:background => bg))
        else
         print("   ".colorize(:background => bg))
        end
      end
      puts
    end
    print('  ')
    ("a".."h").to_a.reverse.each { |letter| print(' '); print(letter); print (' ') }
    puts
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

  def new_piece
    puts "What piece would you like for your promoted pawn (Q,R,B,N)"
    input = gets.chomp
    until ["Q","R","B","N"].include?(input.upcase)
      input = gets.chomp
    end
    input.upcase
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
    puts "enter valid move eg 'e2 e4' you are #{self.color}"
    input = gets.chomp
    until valid?(input)
      puts "invalid entry, make sure format is like: e2 e4"
      input = gets.chomp
    end
    arr = input.split(" ")
    start_pos = arr[0].split("")
    start_pos[0] = 7 - (start_pos[0].ord - "a".ord)
    start_pos[1] = start_pos[1].to_i - 1
    start_pos[1],start_pos[0] = start_pos

    end_pos = arr[1].split("")
    end_pos[0] = 7 - (end_pos[0].ord - "a".ord)
    end_pos[1] = end_pos[1].to_i - 1
    end_pos[1],end_pos[0] = end_pos

    [start_pos,end_pos]
  end
end

def load_game
  puts "load game? (y/n)"
  input = gets.chomp
  if (input == "y")
    puts "what is the file name?"
    input = gets.chomp
    contents = File.read(input)
    g = YAML::load(contents)
    puts "Game is loaded."
  else
    g = Game.new
  end

  g.play
end

load_game
