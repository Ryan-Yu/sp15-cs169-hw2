class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # title_sort symbol was placed in the params
    if params[:title_sort] == "on"
      @movies = Movie.order("title asc")
      @movie_highlight = "hilite"
    elsif params[:date_sort] == "on"
      @movies = Movie.order("release_date asc")
      @date_highlight = "hilite"
    else
      @movies = Movie.all
    end

    # Deal with movie ratings now...
    @all_ratings = Movie.get_possible_ratings()
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
