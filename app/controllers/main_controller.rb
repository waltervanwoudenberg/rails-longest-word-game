require 'open-uri'
require 'json'

class MainController < ApplicationController
  def game
    @grid = params[:grid].to_i
    @new_grid = generate_grid(@grid).join(" ")
    @start_time = Time.now
  end

    def score
    start_time = Time.parse(params[:start_time])
    end_time = Time.now
    grid = params[:new_grid]
    @attempt = params[:attempt]

    @result = run_game(@attempt, grid, start_time, end_time)
  end

  private

    def generate_grid(grid_size)
      # TODO: generate random grid of letters
      grid_size.times.map { (("A".."Z").to_a << "A" + "E" + "U" + "O" + "I").sample }
    end

    def included?(guess, grid)
      guess.split("").all? { |letter| grid.include? letter }
    end

    def compute_score(attempt, time_taken)
      (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
    end

    def run_game(attempt, grid, start_time, end_time)
        result = { time: end_time - start_time }

        result[:translation] = get_translation(attempt)
        result[:score], result[:message] = score_and_message(
        attempt, result[:translation], grid, result[:time])

      result
    end

      def score_and_message(attempt, translation, grid, time)
      if translation
        if included?(attempt.upcase, grid)
          score = compute_score(attempt, time)
          [score, "well done"]
        else
          [0, "not in the grid"]
        end
      else
        [0, "not an english word"]
      end
    end


    def get_translation(word)
      response = open("http://api.wordreference.com/0.8/80143/json/enfr/#{word.downcase}")
      json = JSON.parse(response.read.to_s)
      json['term0']['PrincipalTranslations']['0']['FirstTranslation']['term'] unless json["Error"]
    end

end
