#!/usr/bin/env ruby

# frozen_string_literal: true

class Rechenmeister
  CHEAT_MODE = "tzx"

  module Mode
    attr_reader :name, :ranges

    def initialize(name:, ranges:)
      @name = name
      @op = op
      @ranges = ranges
    end

    def operands(round)
      range = select_range(round)

      solvable_order_for_operands(range.sample, range.sample)
    end

    def solvable_order_for_operands(first, second)
      [first, second]
    end

    def select_range(round)
      case round
      when 0..4
        ranges[0]
      when 5..7
        ranges[1]
      when (7..)
        ranges[2]
      end
    end
  end

  class Add
    include Mode

    def op
      :+
    end

    def solvable_order_for_operands(first, second)
      return [first - 10, second].shuffle if first > 10 && second > 10

      super
    end
  end

  class Substract
    include Mode

    def op
      :-
    end

    def operands(round)
      range = select_range(round)

      solvable_order_for_operands(range[0].sample, range[1].sample)
    end

    def solvable_order_for_operands(first, second)
      return [second, first] if first < second

      super
    end
  end

  class Multiply
    include Mode

    def op
      :*

    end
  end

  class Divide
    include Mode

    def op
      :/
    end

    def solvable_order_for_operands(first, second)
      [first * second, [first, second].sample]
    end
  end

  OP_CHAR = {
    "*": "×",
    "+": "+",
    "-": "-",
    "/": "÷"
  }

  def initialize
    @current_round = 0
    @score = 0

    @all_modes = {
      '1' => Add.new(
        name: "Addieren",
        ranges: [
          (1...10).to_a,
          (1...20).to_a,
          (5...20).to_a,
        ]),
      '2' => Substract.new(
        name: "Substrahieren",
        ranges: [
          [(1...10).to_a, (1...10).to_a],
          [(1...20).to_a, (1...20).to_a],
          [(5...20).to_a, (5...20).to_a]
        ]),
      '$' => Multiply.new(
        name: "Multiplizieren",
        ranges: [
          (2...10).to_a,
          (2...10).to_a,
          (2...10).to_a,
        ]),
      "!" => Divide.new(
        name: "Dividieren",
        ranges: [
          (2...10).to_a,
          (2...10).to_a,
          (2...10).to_a,
        ])
    }

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
    puts "!) Dividieren"
    puts
    print "Wähle 1, 2, $ oder !: "

    unless @mode = @all_modes[gets.strip]
      puts
      puts "Mmmh, das kenn ich gar nicht, nimm doch lieber was anders ;)"
      puts
      choose_mode
      return
    end

    puts
    puts "OK, dann rechnen wir #{@mode.name}!"
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
      @start_time = Time.now
      puts "Super #{@name}, dann rechnen wir #{@max_rounds} Runden. Auf geht es!"
      puts
    end
  end

  def finish
    duration = Time.now - @start_time

    # 30 seconds for each excercise (round) before we start taking penalties
    final_score = [
      ((@max_rounds * 30) / duration).round * 60,
      # More rounds more achievable play time...
      (@max_rounds * 2),
      # ...but capped at 90 minutes
      90
    ].min
    
    if final_score > 0
      system "ponysay --pony rainbowsalute 'Toll #{@name}, du hast #{final_score} Spielminuten gewonnen!'"
      puts
    else
      system "ponysay --pony rarityponder 'Schade #{@name}, du hast zu lange gebraucht. 5 Spielminuten gibt es als Trost <3'"
      puts
    end

    puts

    exit
  end

  def start
    finish if @current_round >= @max_rounds

    first, second = @mode.operands(@current_round)

    system "clear"
    print "Deine Aufgabe ist: #{first} #{OP_CHAR[@mode.op]} #{second} = "
    while result = gets.strip
      if @cheat_mode
        result = eval(result)
      end

      if result.to_i == first.send(@mode.op, second)
        break
      else
        print "Das war leider falsch. Probier es doch nochmal: #{first} #{OP_CHAR[@mode.op]} #{second} = "
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
