require '/pieces.rb'

class Game

end

class Board
  attr_accessor :board
  def initialize
    @board = make_board
  end

  def make_board
    board = Array.new(8) { Array.new(8) }
    board.each do |row|
      row.each do |column|


      end
    end
    #make an array of arrays
    #initialize all the correct pieces
  end

  def pretty_print
    #self.whatever
    self.each do |row|
      puts row
    end
  end

end

class Player

end
