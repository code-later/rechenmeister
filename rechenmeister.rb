# frozen_string_literal: true

class Rechenmeister
  CHEAT_MODE = "tzx"

  def initialize
    @current_round = 0
    @score = 0

    intro
  end

  def intro
    puts "** Willkommen beim Rechenmeister **"
    puts

    select_name

    choose_mode

    choose_rounds

    start
  end

  def select_name
    print "Wie ist denn dein Name? "
    @name = gets.strip

    if @name == CHEAT_MODE && ENV["CHEAT"]
      @cheat_mode = true
    end

    puts
    puts "Hallo #{@name}, dann lass mal ein bisschen rechnen :)"
    puts
  end

  def choose_mode
    puts "Was möchtest du rechnen?"
    puts "1) Addieren"
    puts "2) Substrahieren"
    puts "$) Multiplizieren"
    puts
    print "Wähle 1, 2 oder $: "
    @mode = gets.strip

    case @mode
    when '1'
      @mode_name = "Addieren"
      @op = :+
      @range = [
        (1...10).to_a,
        (10...20).to_a,
        (15...25).to_a,
      ]
    when "2"
      @mode_name = "Substrahieren"
      @op = :-
      @range = [
        (1...10).to_a,
        (1...20).to_a,
        (1...30).to_a,
      ]
    when "$"
      @mode_name = "Multiplizieren"
      @op = :*
      @range = [
        (1...5).to_a,
        (3...7).to_a,
        (5...10).to_a,
      ]
    else
      puts
      puts "Mmmh, das kenn ich gar nicht, nimm doch lieber was anders ;)"
      puts
      choose_mode
      return
    end

    puts
    puts "OK, dann rechnen wir #{@mode_name}!"
    puts
  end

  def choose_rounds
    puts "Wie viele Runden magst du rechnen?"
    print "Runden: "
    @max_rounds = gets.strip.to_i
    puts

    if @max_rounds > 100
      puts "#{@max_rounds} sind vielleicht ein bisschen viel, denkst du nicht?"
      puts "Versuch es mal mit weniger."
      puts
      choose_rounds
    else
      puts "Super #{@name}, dann rechnen wir #{@max_rounds} Runden. Auf geht es!"
      puts
    end
  end

  def finish
    puts "Toll #{@name}, du hast #{@score} von #{@max_rounds} Punkten!"

    exit
  end

  def first_and_second_number
    range = if @current_round > 7
      @range[2]
    elsif @current_round > 4
      @range[1]
    else
      @range[0]
    end


    first = range.sample
    second = range.sample

    return [second, first] if @op == :- && first < second

    return [first - 10, second].shuffle if @op == :+ && first > 10 && second > 10

    [first, second]
  end

  def start
    finish if @current_round >= @max_rounds

    first, second = first_and_second_number

    print "Deine Aufgabe ist: #{first} #{@op} #{second} = "
    while result = gets.strip
      if @cheat_mode
        result = eval(result)
      end

      if result.to_i == first.send(@op, second)
        break
      else
        print "Das war leider falsch. Probier es doch nochmal: #{first} #{@op} #{second} = "
      end
    end
    puts "#{result} ist richtig. Weiter so!"
    @score += 1
    puts

    @current_round += 1
    start
  end
end

rechenmeister = Rechenmeister.new
rechenmeister.start
