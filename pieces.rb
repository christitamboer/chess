
class Pieces
  attr_accessor :position, :color, :symbol, :moves_available, :has_moved, :board_obj
  def initialize(position, color, symbol, board_obj)
    @position = position
    @color = color
    @symbol = symbol
    @moves_available = []
    @has_moved = false
    @board_obj = board_obj
  end

  def valid_moves
    self.moves.select do |move|
      #duplicate piece?
      #p move
      !self.move_into_check?(move)
    end
  end

  def move_into_check?(pos) #return true or false
    board_dup = self.board_obj.dup #this is a board object
    board_dup.move!(self.position, pos)
    board_dup.checked?(self.color)
  end
end

class SlidingPieces < Pieces
  #Queen, Bishop, Rook
  def moves
    board = self.board_obj.board
    self.moves_available = []
    if (self.move_dirs == "both")
      @moves_available += self.diagonal(board)
      @moves_available += self.horizontal_vertical(board)
    elsif (self.move_dirs == "horizontal/vertical")
       @moves_available += self.horizontal_vertical(board)
    else
      @moves_available += self.diagonal(board)
    end

    @moves_available
  end

  def find_avail_moves(board,dir_arr)
    available_moves = []
    until dir_arr.empty?
      position = self.position.dup
      diag_next = dir_arr.shift
      loop do
        position[0] += diag_next[0]
        position[1] += diag_next[1]
        break if position[0] > 7 || position[1] > 7 || position[0] < 0 || position[1] < 0
        if self.board_obj.same_color_piece?(position[0],position[1],self.color)
          break
        elsif self.board_obj.opposite_color_piece?(position[0],position[1],self.color)
          available_moves << position.dup
          break
        else
          available_moves << position.dup
        end
      end
    end

    available_moves
  end

  def diagonal(board)
    #self.position
    available_moves = []
    diag_pos = [
      [-1, -1],
      [1, 1],
      [1, -1],
      [-1, 1]
    ]

    available_moves = find_avail_moves(board,diag_pos)
  end

  def horizontal_vertical(board)
    #self.position
    available_moves = []
    diag_pos = [
      [0, 1],
      [0, -1],
      [1, 0],
      [-1, 0]
    ]

    available_moves = find_avail_moves(board,diag_pos)
  end
end

class Queen < SlidingPieces
  def move_dirs
    "both"
  end
end

class Rook < SlidingPieces
  def move_dirs
    "horizontal/vertical"
  end
end

class Bishop < SlidingPieces
  def move_dirs
    "diagonal"
  end
end

class SteppingPieces < Pieces
  #Pawn, Knight, King
end

class Pawn < SteppingPieces
  def one_space_ahead
    board = self.board_obj.board
    piece_ahead = true
    diag_pos = [1* (self.color == "white"? 1 : -1),0]
    position = self.position.dup
    position[0] += diag_pos[0]
    position[1] += diag_pos[1]
    unless (board[position[0]][position[1]].class.superclass.superclass == Pieces)
      self.moves_available << position.dup
      piece_ahead = false
    end
    piece_ahead
  end

  def diagonal_options
    board = self.board_obj.board
    diags = [[1* (self.color == "white"? 1 : -1),-1], [1* (self.color == "white"? 1 : -1),1]]
    diags.each do |pos|
      position = self.position.dup
      position[0] += pos[0]
      position[1] += pos[1]
      if self.board_obj.opposite_color_piece?(position[0],position[1],self.color)
        self.moves_available << position.dup
      end
    end
  end

  def two_spaces_ahead
    board = self.board_obj.board
    if !self.has_moved
      diag_pos = [2* (self.color == "white"? 1 : -1),0]
      position = self.position.dup
      position[0] += diag_pos[0]
      position[1] += diag_pos[1]
      unless position[0] > 7 || position[1] > 7 || position[0] < 0 || position[1] < 0
        unless (board[position[0]][position[1]].class.superclass.superclass == Pieces)
          self.moves_available << position.dup
        end
      end
    end
  end

  def moves
    board = self.board_obj.board
    self.moves_available = []
    piece_ahead = self.one_space_ahead
    diagonal_options
    two_spaces_ahead unless piece_ahead

    self.moves_available
  end
end

class Knight < SteppingPieces
  def moves
    board = self.board_obj.board
    self.moves_available = []
    diag_pos = [[2, 1], [1, 2], [-2, -1], [-1, -2], [-2, 1], [-1, 2], [2, -1], [1, -2]]
    diag_pos.each do |pos|
      position = self.position.dup
      position[0] += pos[0]
      position[1] += pos[1]
      unless position[0] > 7 || position[1] > 7 || position[0] < 0 || position[1] < 0
        self.moves_available << position.dup
      end
    end

    self.moves_available
  end
end

class King < SteppingPieces
  def moves
    board = self.board_obj.board
    self.moves_available = []
    diag_pos = [[0, 1], [0, -1], [1, 0], [-1, 0], [-1, -1], [1, 1], [1, -1], [-1, 1]]
    diag_pos.each do |pos|
      position = self.position.dup
      position[0] += pos[0]
      position[1] += pos[1]
      unless position[0] > 7 || position[1] > 7 || position[0] < 0 || position[1] < 0
        unless self.board_obj.same_color_piece?(position[0],position[1],self.color)
          self.moves_available << position.dup
        end
      end
    end

    self.moves_available
  end
end