class Mastermind
  attr_accessor :comp_choice, :user_choice, :guesses

  COLORS = "RGBYOP".split("")

  def initialize
    @comp_choice = comp_guess
    @user_choice = []
    @guesses = 10
  end


  def comp_guess
    colors = "RGBYOP".split('')
    comp_select = []
    4.times do
      comp_select << colors.sample
    end

    comp_select
  end

  def game_won?
    exact_matches == 4
  end

  def exact_matches#(user_choice) #return integer
    exact_match = 0
    (0...@user_choice.length).each do |i|
      exact_match += 1 if @comp_choice[i] == @user_choice[i]
    end

    exact_match
  end

  def near_matches #return integer
    near_inc = 0
    @comp_choice.uniq.each do |color|
      near_inc += [@comp_choice.count(color),@user_choice.count(color)].sort[0]
    end

    near_inc
  end

  def valid_choice?(arr)
    colors = "RGBYOP".split('')
    arr.length == 4 && (arr - COLORS == [])

  end

  def user_choice
    puts "choose four colors (RGBYOP)"

    begin
      user_in = gets.chomp.upcase
      valid_choice?(user_in.split(""))
    rescue ArgumentError => e
      puts "Wrong input"
      retry
    end
  end

  def result(exact, near)
    puts "Exact matches: #{exact}. Near matches: #{near}."
    puts "Guesses remaining: #{@guesses}"
  end

  def run
    until game_won? || (@guesses < 1)
      @user_choice = user_choice.split("")
      next unless (valid_choice?(@user_choice))


      @guesses -= 1

      near, exact = near_matches, exact_matches

      result(exact, near)

    end

    if game_won?
      puts "You won!"
    else
      puts "You lost!"
    end

  end


end

Mastermind.new.run