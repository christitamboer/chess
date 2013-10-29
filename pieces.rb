
class Pieces
  attr_accessor :position, :color, :symbol, :moves_available, :has_moved
  def initialize(position, color, symbol)
    @position = position
    @color = color
    @symbol = symbol
    @moves_available = []
    @has_moved = false
  end


  def moves
  end
end

class SlidingPieces < Pieces
  #Queen, Bishop, Rook

  def moves(board)
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
        #check a single diagonal direction
        position[0] += diag_next[0]
        position[1] += diag_next[1]

        if position[0] > 7 || position[1] > 7 || position[0] < 0 || position[1] < 0
          break
        end

        if board[position[0]][position[1]].class.superclass.superclass == Pieces

          if board[position[0]][position[1]].color == self.color
            break
          else
            available_moves << position.dup
            break
          end

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
  diag_pos = [
    [0,1* (self.color == "white"? 1 : -1)]
  ]
  #check if one space vertical is occupied
  #if it isn't, that's a move, and then check if has_moved
  #check if diagonals are occupied by an enemy piece
  #if so, that's an available move, otherwise not
  if !self.has_moved
    diag_pos = [
      [0,2* (self.color == "white"? 1 : -1)]
    ]
    #if no piece in either one space vertical or two, then available move

end

class Knight < SteppingPieces
  def moves
    diag_pos = [
      [2, 1],
      [1, 2],
      [-2, -1],
      [-1, -2],
      [-2, 1],
      [-1, 2],
      [2, -1],
      [1, -2]
    ]

    diag_pos.each do |pos|
      position = self.position.dup
      position[0] += pos[0]
      position[1] += pos[1]
      unless position[0] > 7 || position[1] > 7 || position[0] < 0 || position[1] < 0
        self.moves_available << position
      end
    end
    self.moves_available #blah
  end
end

class King < SteppingPieces
  def moves
    diag_pos = [
      [0, 1],
      [0, -1],
      [1, 0],
      [-1, 0],
      [-1, -1],
      [1, 1],
      [1, -1],
      [-1, 1]
    ]

    diag_pos.each do |pos|
      position = self.position.dup
      position[0] += pos[0]
      position[1] += pos[1]
      unless position[0] > 7 || position[1] > 7 || position[0] < 0 || position[1] < 0
        self.moves_available << position
      end
    end
    self.moves_available
  end
end