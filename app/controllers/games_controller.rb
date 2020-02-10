require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @start_time = Time.now
    i = 0
    @letters = []
    letter = ('A'..'Z').to_a
    while i < 10
      @letters << letter.sample
      i += 1
    end
    @letters
  end

  def timer(start_time, end_time)
    (end_time - start_time).to_i
  end

  def good_english_word?(attempt)
    url = 'https://wagon-dictionary.herokuapp.com/' + attempt
    verify_dictionary = open(url).read
    hash_dictionary = JSON.parse(verify_dictionary)
    hash_dictionary["found"]
  end

  def word_in_grid?(grid, attempt)
    hash_attempt = Hash.new(0)
    hash_grid = Hash.new(0)
    attempt.upcase.split("").each { |letter| hash_attempt[letter] += 1 }
    grid.each { |key| hash_grid[key] += 1 }
    hash_attempt.each do |letter, number|
      return false if number > hash_grid[letter]
    end
    return true
  end

  def run_game(attempt, grid, start_time, end_time)
    return { message: "not an english word", score: 0 } unless good_english_word?(attempt)
    return { message: "not in the grid", score: 0 } unless word_in_grid?(grid, attempt)

    time = timer(start_time, end_time)
    score = attempt.length.to_i * 1000 - time
    { time: time,
      score: score,
      message: "well done" }
  end

  def score
    # raise
    @word = params[:word]
    @score = run_game(@word, @letters.join, @start_time, @end_time)
  end
end
