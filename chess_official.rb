require './pieces.rb'

class Game

end

class Board
  attr_accessor :board
  def initialize
    @board = make_board
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

    board[3][3] = Queen.new([3,3],"white","B")

    board
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

    return nil
  end

end

class Player

end
