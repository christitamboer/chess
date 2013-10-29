class Hangman

  def initialize(human_chooser = 1)
    @guesser, @chooser = ComputerPlayer.new, HumanPlayer.new if (human_chooser == 1)
    @chooser, @guesser = ComputerPlayer.new, HumanPlayer.new if (human_chooser == 0)
    @guesser, @chooser = HumanPlayer.new, HumanPlayer.new if (human_chooser == 2)
    @chooser, @guesser = ComputerPlayer.new, ComputerPlayer.new if (human_chooser == 3)
    @guesses_left = 8
    @used_letters = []
  end



  def run

    @chooser.choose_word
    @guesser.cut_words(@chooser.revealed_letters.length)
    p @chooser.revealed_letters
    until game_complete?
      @guesser.prompt
      #p @chooser.chosen_word

      next_guess = @guesser.make_guess(@used_letters)
      next if @used_letters.include?(next_guess)

      @used_letters << next_guess
      positions = @chooser.result(@used_letters)

      @guesser.update_words_arr(positions, @used_letters[-1])

      puts "#{@chooser.revealed_letters}"

    end
    puts "WINNER!"
  end

  def game_complete?
    @chooser.word_guessed?
  end

end

class HumanPlayer
  attr_accessor :revealed_letters

  def initialize

  end

  def cut_words(a)
  end

  def update_words_arr(blank1, black2)
  end

  def prompt
    puts "Guess a single letter:"
  end

  def make_guess(used_letters) #return string
    user_input = gets.chomp.downcase
    until valid?(user_input)
      user_input = gets.chomp.downcase
    end
    user_input
  end

  def valid?(str) #return bool
    str.length == 1 && str =~ /[a-z]/
  end

  def word_guessed?
    !@revealed_letters.include?("-")
  end

  def valid_positions?(positions)
    valid = true
    positions.each do |str|
      #str.to_i
      if (str.to_i > @revealed_letters.length || (str.to_i == 0 && str != "0") )
        valid = false
      end
    end
    valid
  end



  def choose_word
    puts "Write in the length of a word"
    word_length = Integer(gets.chomp)
    @revealed_letters = (0...word_length).map { "-" }
  end


  def result(used_letters)
    puts "Enter positions of #{used_letters[-1]}"
    puts "Reminder: enter 0 for bad guess"
    positions = gets.chomp.split(' ')

    until valid_positions?(positions)
      positions = gets.chomp.split(' ')
    end

    if (positions.first != "0")
      good_guess(positions,used_letters[-1])
    else
      #bad_guess
    end

    positions
  end

  def good_guess(positions,last_letter)

    positions.each do |index|
      @revealed_letters[index.to_i-1] = last_letter
    end
    @revealed_letters
  end




end

class ComputerPlayer
  attr_accessor :revealed_letters, :chosen_word

  def initialize
    @words = create_dictionary
  end

  def create_dictionary
    words = []
    File.foreach('dictionary.txt') do |line|
      words << line.chomp
    end

    words
  end

  def result(used_letters)
    last_guess = used_letters[-1]
    positions = []
    @chosen_word.each_with_index do |letter,index|
      if (last_guess == letter)
        @revealed_letters[index] = last_guess
        positions << index+1
      end

    end

    #@revealed_letters
    positions
  end

  def update_words_arr(positions_arr, last_letter)
    if positions_arr[0] == "0" #bad guesses
      @words = @words.select do |word|
        !word.include?(last_letter)
      end
    else #good guesses
      @words = @words.select do |word|
        checker = true
        positions_arr.each do |i|
          checker = false if word[i.to_i-1] != last_letter
        end

        checker
      end
      #update by comparing
    end

  end

  def word_guessed?()
    @chosen_word == @revealed_letters
  end

  def choose_word #returns array
    @chosen_word = @words.sample.split("")
    puts @chosen_word
    @revealed_letters = (0...@chosen_word.length).map { "-" }
  end

=begin
  def make_guess # returns letter
    ('a'..'z').to_a.sample
  end
=end
  def cut_words(length)
    @words = @words.select do |word|
      word.length == length
    end
  end

  def make_guess(used_letters)
    frequency_finder(used_letters)
  end

  def frequency_finder(used_letters)
    #puts "Used letter: #{@words}"
    letters_hash = Hash.new(0)
    @words.each do |word|
      word.split("").each do |letter|
        letters_hash[letter] += 1 unless used_letters.include?(letter)
      end
    end
    #puts @words.length
    letters_hash.invert.sort.reverse.first[1]
  end


  def prompt
  end


end

Hangman.new(2).run