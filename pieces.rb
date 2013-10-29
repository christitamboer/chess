
class Pieces
  attr_accessor :position, :color
  def initialize(position, color, symbol)
    @position = position
    @color = color
    @symbol = symbol
  end


  def moves
  end
end

class SlidingPieces < Pieces
  #Queen, Bishop, Rook
  def moves
  end

end

class Queen < SlidingPieces
  def move_dirs
  end
end

class Rook < SlidingPieces
  def move_dirs
  end
end

class Bishop < SlidingPieces
  def move_dirs
  end
end

class SteppingPieces < Pieces
  #Pawn, Knight, King

end

class Pawn < SteppingPieces

end

class Knight < SteppingPieces

end

class King < SteppingPieces

end