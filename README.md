Rails Intro: Add Features to RottenPotatoes
===========================================

In this homework you will add features to the RottenPotatoes teaching
app and deploy the enhanced app on Heroku.  We will run
live integration tests against your deployed version.

You will add two features  to the  RottenPotatoes "List All Movies" page
that will familiarize you 
with the interactions between controllers and views:

0. Allow movies to be sorted by either title or release date;

0. Filter the list so only movies with certain ratings (PG, G, etc.) are
shown. 

General advice:  This homework involves modifying RottenPotatoes in
various ways.  Git is your friend: commit frequently in case you
inadvertently break something that was working before!  That way you can
always back up to an earlier revision, or just visually compare what
changed in each file since your last "good" commit. 

*Remember, commit early and often!*

# Part 1: get RottenPotatoes running locally and on Heroku

**Goal:** Create a new Rails app for RottenPotatoes, populate it with
our starter code, and get it running locally as well as on Heroku.

The provided skeleton code is **not** a complete and ready-to-run Rails
app: we want you to get used to the process of bootstrapping a new app
from scratch.  You may find yourself looking up the specific commands
and options to do some of the following steps; that's part of the
retention process.

0. Create a brand-new Rails app called `rottenpotatoes` (you can choose a
different name, but the provided skeleton code won't work
out-of-the-box).  You should now have a `rottenpotatoes` directory,
which is the "app root directory" in Rails parlance.  **Hint:** To
create a brand-new Rails app, you don't need to create all its files
from scratch.  "Use the Google" to figure out how Rails itself can
create the "skeleton" of a new app for you.

0. Put that directory immediately under Git version control, and add all
the files in it.  Commit.

0. Replace the following specific files under `rottenpotatoes` with
their counterparts from the provided
`rottenpotatoes` starter code directory:

* Gemfile
* app/assets/stylesheets/application.css
* app/controllers/movies_controller.rb
* app/views/layouts/application.html.haml
* app/views/movies/*.html.haml
* app/models/movie.rb
* config.ru 
* db/seeds.rb



0. When you generate the Rails scaffolding, you are given a default global HTML layout in `app/views/layouts/application.html.erb`.  However, we give a pre-written HAML template instead at `app/views/layouts/application.html.haml`.  This means you should remove `app/views/layouts/application.html.erb` so that Rails uses the HAML template instead.

Commit the new versions of these files.

* Self-check: the `Gemfile` specifies what libraries (gems) this app
will use, and some constraints on the compatible versions of gems.  How
do you actually cause the gems to be installed (or have the
versions checked for compatibility, if you already have the gems
installed), and what file is created to record the definitive versions
of gems that will actually be used at runtime?  (Check your answer
before proceeding, to avoid an installation pitfall!)
 
> Run `bundle install --without production`, which creates
> `Gemfile.lock`.  The reason for `--without production` is to avoid
> trying to install gems used only in production.  In this case, the gem `pg`
> is needed in production since Heroku uses the PostgreSQL database, but
> if you try to install it locally, it will fail unless you happen to
> already have a full installation of Postgres itself!  We don't need it
> locally because we use the `sqlite3` database for development.

0. The app won't run yet because no routes mapping URIs to controller
actions have been defined, and no database has been created.  For this
app, all we need are the four basic 
CRUD routes for `Movie` resources.  What file do you need to modify to
add these routes, and what single line can you add that will set up all
the basic CRUD-for-a-resource routes?

> Add the line `resources :movies` to `config/routes.rb`.  Go ahead, do it.

At this point, run `rake routes` to verify you have basic RESTful routes
for the movies model.

0. The app still won't run because we haven't created a database.  (We
don't mean that the database has no movies in it, though that also
happens to be true: we mean there is no database at all!)  In other
words, we have not run the initial migration to create the schema.

* What command should we use to cause Rails to generate a migration
file for us that will add the columns
title (string), release date (datetime), rating (string), and
description (text) to a table called `movies`?

> `rails generate migration AddFieldsToMovies title:string release_date:datetime rating:string description:text`

Take a look at the migration file that was created.  The `change` method
defines what happens when the migration is applied.

* Why will this migration **fail** if applied right now, and how should
you fix it?  (Hint: what
assumption does the `change` code appear to make about the database schema?)

> The `change` method assumes the `movies` table already exists, and adds
> columns to it.  One fix is to add `create_table :movies` (or
> `create_table "movies"`) at the beginning of the `change` method.

Apply the fix and then run the migration (hint: `rake` is involved).

At this point you should be able to run the app locally with `rails
server` and ensure you can visit 
`localhost:3000` in a browser.

0. Deploy the app to Heroku (review the procedure in the ESaaS Appendix if
necessary). Here's a brief overview of the workflow:
  - Start by creating a new Heorku app and configuring your rottenpotatoes git repository to have a Heroku remote
  - Heroku is going to require that you have a database ready and waiting when you push your code, else the deploy will fail.  A Heroku PostgreSQL database can be created for your app by running `heroku addons:add heroku-postgresql`.
  - Go ahead and deploy your app with the proper git push command
  - At this point, visiting the '/movies' route will still fail.  This is because you have a DB stood up, but it does not have the most up-to-date schema instantiated for your app (in fact, there is no schema at all since we _just_ made the DB).  We can run all of our DB migrations on our Heroku deployed app by running `heroku run rake db:migrate`.  This is the same as a local `rake db:migrate` except that it runs it on your cloud-deployed Heroku app.
  - Optionally, you can run `heroku run rake db:seed` to populate some dummy movie entries

0. Verify you can visit the app as deployed on Heroku. You should be able to browse to the '/movies' route and click around without issues.  This is your
starting point.  Get to this point before continuing, or you'll be in a
world of pain.  **A world of pain.**

# Add a feature: sort the list of all movies

**Goal:** Make it possible to sort the list of all movies either
alphabetically by title or in order by release date.  

Specifically, on the List All Movies page, you'll make two changes to the column
headings for 'Movie Title' and 'Release Date' and the associated
controller logic:

0. The Movie Title and Release Date column headings will become
clickable links. 
Clicking one of them should cause the list to be reloaded but sorted in
ascending order on that column.  For example, clicking the 'release
date' column heading should redisplay the list of movies with the
earliest-released movies first; clicking the 'title' field should list
the movies alphabetically by title.  (For movies whose names begin with
non-letters, the sort order should match the behavior of String#<=>.)

0. When the listing page is redisplayed with sorting-on-a-column enabled,
the column header that was selected for sorting should appear with a
yellow background, as shown here:

![Screenshot of yellow table header][https://github.com/saasbook/hw/blob/master/rails-intro/table-header-screenshot.png]


### IMPORTANT for grading purposes: 

Certain HTML elements must have specific IDs in order for the autograder
to work. These have been set up correctly in the skeleton code provided,
so please don't change them:

+ The column header link (that is, the `<a>` tag) for sorting by title
should have the HTML element id `title_header`.  
+ The link for sorting by ‘release date’ should have the HTML element id
`release_date_header`.  
+ The table containing the list of movies should have the HTML element
id `movies`.

Turning the column headings into links that sort the movies
-----------------------------------------------------------

* Self-check: Based on Rails' use of convention over configuration, in
what file should you expect to find the view code for listing all
movies?

> `app/views/movies/index.html.haml`

> Explanation: in Rails apps, the `views` directory contains all app
> views organized by model, so `views/movies` are the views for actions
> related to the Movie model.  `index` is the conventional name for the
> RESTful action  "list all instances of this resource type".  The `.haml`
> extension indicates that the Haml preprocessor should be called to
> render the view.  That preprocessor will strip off the `.haml` part and
> leave a `.html` file, telling Rails that it will be returning an HTML
> page to Rack.

* Self-check: What controller action generates the list of all movies?

> `MoviesController#index` in `app/controllers/movies_controller.rb`

* Self-check: What route (URI and HTTP verb) triggers that action, and
what route helper method would generate that route for you?  (Hint: use
`rake routes`)

> The route is `GET /movies` and the helper method is `movies_path` (no
> arguments). 

As an intermediate step, modify the view so that clicking on the "Movie
title" table header causes this controller action to be invoked.  (Hint:
consider using the `link_to` helper.  Having the Rails documentation
handy from `apidock.com` will be very helpful.)

You now need to somehow signal the controller action if it was invoked
by clicking on the Movie Title link or some other way.  We will take
advantage of the fact that you can pass additional arguments to the
RESTful route helpers, and these will get added to the URL as URL
parameters in the query-string and then in turn get parsed into
`params`.

In the "intermediate step" above, somewhere in your view you should be
generating a URL by calling `movies_path()` with no arguments.  Try
replacing that call with `movies_path(:foo => 'bar')`.

* When this view is rendered, what URL is generated for the link now?

>  `/movies?foo=bar`

Verify (by using the interactive debugger, or by making `params` visible
in one of your views) that the call to the `index` action now has
`params[:foo] == "bar"`.

Use the results of this observation to pass a parameter to the `index`
action such that, if the parameter is present, the collection `@movies`
is passed to the view in title-sorted order.  **Hint:** Databases are
good at sorting results.  Look at the ActiveRecord documentation to see
how to get the database to return a properly-sorted collection for you,
rather than sorting `@movies` after the database query returns.

Once you've got the idea, use the same technique to make movies sortable
by date when the Release Date table header is clicked.

Last step: when the movie list has been sorted by one of those columns,
the corresponding column header should appear yellow in the list view.
The file `app/assets/stylesheets/application.css` file should contain
the following style rule you can use:

```css
table#movies th.hilite {
  background-color: yellow;
}
```

Modify the view and controller action so that the table headings (`th`
tags) are conditionally given the appropriate CSS class to match the
above style rule.  A table heading should only be yellow if the current
list of movies is sorted by that header.

**Don't put code in your views!**  The view shouldn't have to sort the
collection itself--its job is just to show stuff.  The controller should
spoon-feed the view exactly what is to be displayed. 

## Commit

Commit early and often!  When you get to a working solution for this
part, you might even want to give the commit a tag (symbolic name) such
as "part1" in case you ever need to diff against it or go back to it.
(Try `git help tag` for details.)

# Part 2: Filter the list of movies

Enhance RottenPotatoes as follows.  At the top of the All Movies
listing, add some checkboxes that allow the user to filter the list to
show only movies with certain MPAA ratings: 

![Screenshot of filter checkboxes][https://github.com/saasbook/hw/blob/master/rails-intro/filter-screenshot.png]

When the Refresh button is pressed, the list of movies is redisplayed
showing only those movies whose ratings were checked. 

This will require a couple of pieces of code.  We have provided the code
that generates the checkboxes form, which you can include in the
`index.html.haml` template:

```haml
= form_tag movies_path, :method => :get do
  Include: 
  - @all_ratings.each do |rating|
    = rating
    = check_box_tag "ratings[#{rating}]"
  = submit_tag 'Refresh'
```

BUT, you have to do a bit
of work to use the above code: as you can see, it expects the variable
@all_ratings to be an 
enumerable collection of all possible values of a movie rating, such as
`['G','PG','PG-13','R']`.  The controller method needs to set up this
variable.  And since the possible values of movie ratings are really the
responsibility of the Movie model, it's best if the controller sets this
variable by consulting the Model.  Hence, you should create a class
method of Movie that 
returns an appropriate value for this collection. 

You will also need code that figures out (i) how to figure out which
boxes the user checked and (ii) how to restrict the database query based
on that result. 

Regarding (i), try viewing the source of the movie listings with the
checkbox form, and you'll see that the checkboxes have field names like
`ratings[G]`, `ratings[PG]`, etc.  This trick will cause Rails to aggregate
the values into a single hash called `ratings`, whose keys will be the
names of the checked boxes only, and whose values will be the value
attribute of the checkbox (which is "1" by default, since we didn't
specify another value when calling the `check_box_tag` helper).  That is,
if the user checks the 'G' and 'R' boxes, params will include as one if
its values `:ratings=>{"G"=>"1", "R"=>"1"}`.  Check out the Hash
documentation for an easy way to grab just the keys of a hash, since we
don't care about the values in this case.

Regarding (ii), you'll probably end up replacing `Movie.all` in the
controller method with
`Movie.find`, which has various options to help you restrict the database
query.   

### IMPORTANT for grading purposes: 

+ Your form tag should have the id `ratings_form`
+ The form submit button for filtering by ratings should have an HTML element id of `ratings_submit`. 
+ Each checkbox should have an HTML element id of `ratings_#{rating}`,
where the interpolated rating should be the rating itself, such as
"PG-13", "G". i.e. the id for the checkbox for PG-13 should be
`ratings_PG-13`. 

### Hints and caveats:

+ Make sure that you don't break the sorted-column functionality you
added  previously!  That is, sorting by column headers should still work,
and if the user then clicks the "Movie Title" column header to sort by
movie title, the displayed results should both be sorted and be limited
by the Ratings checkboxes. 

+ If the user checks (say) 'G' and 'PG' and then redisplays the list,
the checkboxes that were used to filter the output should appear checked
when the list is redisplayed.  This will require you to modify the
checkbox form slightly from the version we provided above. 

+ The first time the user visits the page, all checkboxes should be
checked by default (so the user will see all movies).  For now, ignore
the case when the user unchecks all checkboxes--you will get to this in
the next part. 

+ Don't put code in your views!  Set up some kind of instance variable
in the controller that remembers which ratings were actually used to do
the filtering, and make that variable available to the view so that the
appropriate  boxes can be pre-checked when the index view is reloaded. 

# Part 3: Remember the sorting and filtering settings 

OK, so the user can now click on the "Movie Title" or "Release Date"
headings and see movies sorted by those columns, and can additionally
use the checkboxes to restrict the listing to movies with certain
ratings only.  And we have preserved RESTfulness, because the URI itself
always contains the parameters that will control sorting and filtering. 

The last step is to remember these settings.  That is, if the user has
selected any combination of column sorting and restrict-by-rating
constraints, and then the user clicks to see the details of one of the
movies (for example), when she clicks the Back to Movie List on the
detail page, the movie listing should "remember" the user's sorting and
filtering settings from before. 

(Clicking away from the list to see the details of a movie is only one
example; the settings should be remembered regardless what actions the
user takes, so that any time she visits the index page, the settings are
correctly reinstated.) 

The best way to do the "remembering" will be to use the `session[]` hash.
The `session` is like the `flash[]`, except that once you set something in
the `session[]` it is remembered "forever" until you nuke the session with
`session.clear` or selectively delete things from it with
`session.delete(:some_key)`.  That way, in the `index` method, you can
selectively apply the settings from the `session[]` even if the incoming
URI doesn't have the appropriate `params[]` set. 

### Hints and caveats

+ If the user explicitly includes new sorting/filtering settings in
`params[]`, the session should not override them.  On the contrary, the
new settings should be remembered in the session. 
+ If a user unchecks all checkboxes, use the settings stored in the
`session[]` hash (it doesn't make sense for a user to uncheck all the
boxes).
+ To be RESTful, we want to preserve the property that a URI that
results in a sorted/filtered view always contains the corresponding
sorting/filtering parameters.  Therefore, if you find that the incoming
URI is lacking the right `params[]` and you're forced to fill them in from
the `session[]`, the RESTful thing to do is to `redirect_to` the new URI
containing the appropriate parameters.  There is an important corner
case to keep in mind here, though: if the previous action had placed a
message in the `flash[]` to display after a redirect to the movies page,
your additional redirect will delete that message and it will never
appear, since the `flash[]` only survives across a single redirect.  To
fix this, use `flash.keep` right before your additional redirect. 

# How to submit:

Deploying your finished app to Heroku by the homework deadline is part
of the grading process.  Even if you have code checked in that works
properly, you still need to also deploy it to Heroku to get full
credit.  

You will submit the URI of your Heroku app and the URI of your
GitHub repo containing your code.
