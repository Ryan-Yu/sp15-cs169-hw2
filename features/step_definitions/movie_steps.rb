# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    Movie.create!(:title => movie['title'], :rating => movie['rating'], :release_date => movie['release_date'], :director => movie['director'])
  end
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.body is the entire content of the page as a string.
  list_of_movies_in_order = page.all("table#movies tbody tr td[1]").map {|element| element.text}
  assert(list_of_movies_in_order.index(e1) < list_of_movies_in_order.index(e2))
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  # We want to uncheck all of our movies
  if uncheck == "un"
    ratings_list = rating_list.split(',').map(&:strip)
    ratings_list.each do |rating|
      step %Q{I uncheck "ratings_#{rating}"}
    end
  # We want to check all of our movies
  else
    ratings_list = rating_list.split(',').map(&:strip)
    ratings_list.each do |rating|
      step %Q{I check "ratings_#{rating}"}
    end
  end
end

Then /I should see all the movies/ do
  array_of_movies = page.all("table#movies tbody tr td[1]").map {|element| element.text }
  number_of_movies_in_table = array_of_movies.size
  number_of_movies_in_database = Movie.all.size
  assert(number_of_movies_in_database == number_of_movies_in_table)
end

Then (/^the director of "(.*)" should be "(.*)"$/) do |movie, dir|
  assert (Movie.find_by_title(movie).director == dir)
end