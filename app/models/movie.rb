class Movie < ActiveRecord::Base
  attr_accessible :title, :rating, :description, :release_date, :director

  # Prefixing with 'self.' makes this a class method
  def self.get_possible_ratings
	return %w[G PG PG-13 R]
  end
end
