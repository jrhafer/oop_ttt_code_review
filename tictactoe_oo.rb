class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                  [[1, 5, 9], [3, 5, 7]]

  def initialize
    @squares = {}
    reset
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def draw
    puts "       |     |"
    puts "    #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "       |     |"
    puts "  -----+-----+-----"
    puts "       |     |"
    puts "    #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "       |     |"
    puts "  -----+-----+-----"
    puts "       |     |"
    puts "    #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "       |     |"
    puts ""
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  def set_square_at(key, marker)
    @squares[key].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def no_markers
    unmarked_keys.size == 9
  end

  def one_square_marked
    unmarked_keys.size == 8
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def offensive_move(player_marker)
    move = nil
    WINNING_LINES.each do |line|
      squares = line.map { |number| @squares[number].marker }
      if squares.count(player_marker) == 2 && squares.count(' ') == 1
        move = line.select { |num| @squares[num].marker == ' ' }.first
      end
    end
    move
  end

  def defensive_move(player_marker)
    move = nil
    WINNING_LINES.each do |line|
      squares = line.map { |number| @squares[number].marker }
      if squares.count(player_marker) == 2 && squares.count(' ') == 1
        move = line.select { |num| @squares[num].marker == ' ' }.first
      end
    end
    move
  end

  def middle_square_available
    unmarked_keys.include?(5) ? 5 : nil
  end

  def middle_square
    5
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = ' '

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def marked?
    marker != INITIAL_MARKER
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end
end

class Player
  attr_reader :marker, :name

  @@marker_options = ['X', 'O']
  @@name_toggle = 'on'

  def initialize
    @marker = assign_marker
    @name = assign_name
  end

  def assign_name
    if @@name_toggle == 'on'
      @@name_toggle = 'off'
      print "Please enter your name: "
      gets.chomp.strip
    else
      ["R2D2", "C3PO", "BB-8"].sample
    end
  end

  def prompt_human_choose_marker
    puts "Which marker would you like to be?"
    puts "Choose 'X' or 'O'"
    gets.chomp.strip.upcase
  end

  def assign_marker
    marker = nil
    if @@marker_options.size > 1
      loop do
        marker = prompt_human_choose_marker
        @@marker_options.include?(marker) ? break : "Invalid Entry!"
      end
    else
      marker = @@marker_options[0]
    end
    @@marker_options.delete(marker)
  end
end

class TTTGame
  ROUNDS_TO_WIN = 5

  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Player.new
    @computer = Player.new
    @current_marker = first_to_move
    @@score = { human: 0, computer: 0 }
    @winning_score = ROUNDS_TO_WIN
  end

  def play
    clear
    loop do
      play_rounds_til_grand_winner
      display_grand_winner
      break unless play_again?
      clear
      reset_board_and_score
    end
    display_goodbye_message
  end

  private

  def play_rounds_til_grand_winner
    loop do
      play_round_tic_tac_toe
      break if winning_score_reached
      sleep(2)
      reset
    end
  end

  def play_round_tic_tac_toe
    display_board
    players_move
    update_score
    display_result
    display_play_another_round
  end

  def display_play_another_round
    space
    puts "Lets play another round." if !winning_score_reached
    space
  end

  def players_move
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end

  def first_to_move
    display_welcome_message unless @current_marker
    choice = nil
    loop do
      puts "Who chooses first to move? (H)uman or (C)omputer/ #{computer.name}?"
      choice = gets.chomp.strip.upcase
      break if ['H', 'C'].include?(choice)
      puts "Invalid Entry!"
    end
    choice == 'C' ? computer_chooses_first_to_move : human_chooses_first_to_move
  end

  def human_chooses_first_to_move
    answer = nil
    loop do
      puts "Who moves first? Enter 'H' for humand and 'C' for Computer: "
      answer = gets.chomp.strip.upcase
      break if ['H', 'C'].include?(answer)
      puts "Invalid Entry!"
    end
    answer == 'H' ? human.marker : computer.marker
  end

  def computer_chooses_first_to_move
    [human.marker, computer.marker].sample
  end

  def clear
    system 'clear'
  end

  def display_welcome_message
    space
    puts "#{human.name}, Welcome to Tic Tac Toe!"
    space
    puts "You will be playing against #{computer.name}"
    space
    puts "The first to win #{ROUNDS_TO_WIN} rounds is the Grand Winner!"
    space
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
    puts ""
  end

  def display_board
    puts "You're a #{human.marker}. #{computer.name} is a #{computer.marker}."
    puts ""
    display_score
    board.draw
    puts ""
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def offensive_move_available
    board.offensive_move(computer.marker)
  end

  def defensive_move_available
    board.defensive_move(human.marker)
  end

  def middle_square_available
    board.middle_square_available
  end

  def best_computer_move
    if offensive_move_available
      then board.offensive_move(computer.marker)
    elsif defensive_move_available
      then board.defensive_move(human.marker)
    elsif middle_square_available
      then board.middle_square
    else
      board.unmarked_keys.sample
    end
  end

  def computer_moves
    board[best_computer_move] = computer.marker
  end

  def update_score
    case board.winning_marker
    when human.marker then @@score[:human] += 1
    when computer.marker then @@score[:computer] += 1
    end
  end

  def winning_score_reached
    @@score.values.include?(@winning_score)
  end

  def display_grand_winner
    space
    if @@score[:human] == @winning_score
      puts "Player is the grand winner!!"
    elsif @@score[:computer] == @winning_score
      puts "Computer is the grand winner!!"
    end
    space
  end

  def display_score
    puts "     ***SCORE***"
    space
    puts "#{human.name}: #{@@score[:human]}   #{computer.name}: \
  #{@@score[:computer]}"
    space
  end

  def display_result
    clear_screen_and_display_board
    case board.winning_marker
    when human.marker then puts "You won!"
    when computer.marker then puts "#{computer.name} won!"
    else
      puts "It's a tie!"
      puts " "
    end
  end

  def human_moves
    display_computer_first_move_choice
    prompt_human_for_move
    square = nil
    loop do
      square = gets.chomp.strip.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end
    board.[]=(square, human.marker)
  end

  def prompt_human_for_move
    puts "Choose a square: #{joinor(board.unmarked_keys)}"
  end

  def display_computer_first_move_choice
    if board.no_markers
      puts "#{computer.name} chose for you to move first"
      space
    elsif board.one_square_marked
      puts "#{computer.name} chose to go first."
      space
    end
  end

  def joinor(numbers, seperator=', ', joiner='or')
    numbers = numbers.map(&:to_s)
    case numbers.size
    when 1 then numbers[0]
    when 2 then "#{numbers[0]} #{joiner} #{numbers[1]}"
    else
      "#{numbers[0..-2].join(seperator)}#{seperator}#{joiner} #{numbers[-1]}"
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.strip.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be 'y' or 'n'"
    end
    answer == 'y'
  end

  def reset
    board.reset
    @current_marker = first_to_move
  end

  def reset_score
    @@score = { human: 0, computer: 0 }
  end

  def reset_board_and_score
    reset
    reset_score
  end

  def human_turn?
    @current_marker == human.marker
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = computer.marker
    else
      computer_moves
      @current_marker = human.marker
    end
  end

  def space
    puts " "
  end
end

game = TTTGame.new
game.play
