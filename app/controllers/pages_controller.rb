class PagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  # index.html.erb/ home/ all_games page
  def index
    set_game_image
    @all_games = Game.all.order('created_at DESC')
  end

  # playhistory.html.erb
  def playhistory
    set_game_image
    @my_games = Game.where('creator' => current_user.username)
    @use = @my_games.last

    @all_plays = Ahoy::Event.order("time DESC").select{ |event|
      event.properties['action'] == 'show' &&
      event.user_id.to_i == current_user.id
    }

    @play_history = []
    @ids = []
    @all_plays.each do |event|
      id = event.properties['id'].to_i
      if !@ids.include?(id)
        @play_history << Game.find(id)
        @ids << id
      end
    end
  end

  # profile.html.erb profile pages
  def profile
    set_game_image
    # find profile based on user
    @user = User.find(params[:id])

    # all games belonging to user
    @my_games = Game.where('creator' => @user.username)
    # my_games with reports and ratings
    @use = @my_games.includes(:reports, :ratings, :visits)

    # my reports
    @my_game_ids = @my_games.map{|game| game.id}
    @my_reports = Report.where(game_id: @my_game_ids)
    # my ratings
    @my_ratings = Rating.where(game_id: @my_game_ids)

    # list of scores
    @ratings_scores = @my_ratings.map{|rating| rating.score }

    # avg for all games
    @all_game_avg = @ratings_scores.sum.to_f/@ratings_scores.length

    # number of total visits to games
    @game_visits = Ahoy::Event.select{ |event| event.properties['action'] == 'show' }

    @visits = []
    @game_visits.each do |visit|
      id = visit.properties['id'].to_i
      if @my_game_ids.include?(id)
        @visits << id
      end
    end

    # ctr (visits to external site)

  end

  # report.html.erb page
  def report
    @game = Game.find(params[:id])
  end

  # reportinfo.htm.erb
  def reportinfo
    allow_at_mention
    @game = Game.find(params[:id])
    @game_id = @game.id
    @user = User.find_by('username' => @game.creator)
    @comments = Comment.where('game_id' => @game_id).reverse
    @report = Report.where('game_id' => @game_id).reverse
    @rating = Rating.where('game_id' => @game_id).reverse
    @site_visits = Visit.where('game_id' => @game_id)

    # number of total visits to games
    @game_visits = Ahoy::Event.select{
      |event|
      event.properties['action'] == 'show' &&
      event.properties['id'].to_i == @game_id
    }

    @total_ratings = []
    Rating.find_each do |rating|
      if rating.game_id == @game.id && @game.user_id == @game.user_id
        @total_ratings << rating.score.to_f
      end
    end
    if @total_ratings.length > 0
      @avg = @total_ratings.sum/@total_ratings.length
    else
      @avg = 0
    end
  end

  # show.html.erb/ single game page
  def show
    allow_at_mention
    temp_user

    @game = Game.find(params[:id])
    @webpage = @game.webpage
    @comment_search = Comment.where('game_id' => @game.id)
    @comments = @comment_search.includes(:user, :subcomments).reverse
    @sub_comments = Subcomment.all.includes(:user).reverse

    # number of visits to game
    @visits = []
    Ahoy::Event.find_each do |event|
      property = event.properties
      if property['action'] == 'show' && property['id'] == @game.id.to_s
        @visits << property
      end
    end

    # all ratings for game
    @total_ratings = []
    Rating.find_each do |rating|
      if rating.game_id == @game.id && @game.user_id == @game.user_id
        @total_ratings << rating.score.to_f
      end
    end
    if @total_ratings.length > 0
      @avg = @total_ratings.sum/@total_ratings.length
    else
      @avg = 0
    end
  end

  # all add methods

  # create a new comment
  def add_comment
    @new_comment = Comment.new(comment_params)
    @new_comment.save

    @notification = Notification.new(notification_params)

    if @notification.valid? && params[:mention][:mentioned].length > 0
      @notification.save
      @recipient = User.where('username' => params[:mention][:mentioned])
      @notification.update('recipient_id' => @recipient[0].id)
    end

    @game = Game.find(@new_comment.game_id)

    respond_to do |format|
      format.html { redirect_to "/pages/#{@game.id}", notice: "Comment Submited" }
      format.js   {}
      format.json { render json: @new_comments, status: :created, location: @new_comments }
    end

    @comment_search = Comment.where('game_id' => @game.id)
    @comments = @comment_search.includes(:user).reverse

  end

  # create a new game (function on newgame.html.erb)
  def add_game
    params[:games][:name].capitalize!
    @newgame = Game.new(game_params)
    @newgame.save
    redirect_to "/profile/#{current_user.id}"
  end

  # create a new report (function on report.html.erb)
  def add_report
    @newreport = Report.new(report_params)
    if @newreport.valid? && Report.where('user_id = ? and game_id = ?', @newreport.user_id , @newreport.game_id).blank?
      @newreport.save
      redirect_to "/profile/#{current_user.id}"
    elsif @newreport.valid?
      redirect_to "/report/#{@newreport.game_id}", alert: "Can't report a game more then once. #{view_context.link_to("View Reports?", "/reportinfo/#{@newreport.game_id}")}"
    else
      redirect_to "/report/#{@newreport.game_id}", alert: "An error occured please try again"
    end
  end

  # create a new rating (function)
  def add_rating
    @rating = Rating.new(rating_params)
    respond_to do |format|
      if @rating.valid? && Rating.where('user_id = ? and game_id = ?', @rating.user_id, @rating.game_id).blank?
        @rating.save
        format.html { redirect_to @rating, notice: "Rating Submited" }
        format.js   {}
        format.json { render json: @rating, status: :created, location: @rating }
      elsif @rating.valid? && @rating.score == nil
        format.html { redirect_to @rating, notice: "Cannot Rate 0. Try again." }
        format.js   {}
        format.json { render json: @rating, status: :created, location: @rating }
      elsif @rating.valid?
        @updated_rating = Rating.where('user_id = ? and game_id = ?', @rating.user_id, @rating.game_id)
        @updated_rating.update(rating_params)
        @notice = "Updated Rating. #{view_context.link_to("View Rating?", "/reportinfo/#{@rating.game_id}#rating_head")}"
        format.html { redirect_to @rating, notice: 'Rating was successfully created.' }
        format.js   {}
        format.json { render json: @rating, status: :created, location: @rating }
      else
        format.html { redirect_to @rating, notice: "Error has occued. Please try again" }
        format.js   {}
        format.json { render json: @rating, status: :created, location: @rating }
      end
    end
    @total_ratings = []
    @rating.score.times do
      @total_ratings << @rating.score
    end
  end

  def add_subcomment
    @sub_comment = Subcomment.new(subcomment_params)
    @sub_comment.save

    respond_to do |format|
      format.html { redirect_to @sub_comment, notice: "Rating Submited" }
      format.js   {}
      format.json { render json: @sub_comment, status: :created, location: @sub_comment }
    end

    @comment = Comment.find(@sub_comment.comment_id)
    @game = Game.find(@comment.game_id)
    @comment_search = Comment.where('game_id' => @game.id)
    @comments = @comment_search.includes(:user).reverse
  end

  # intended for outsite site visit
  def add_visit
    @visit = Visit.new(visit_params)
    @visit.save
    redirect_to '/', notice: "Site opened in new tab."
  end


  # all variable sets
  # allow @mention
  def allow_at_mention
    @usernames = []
    User.all.each do |user|
      @usernames << user.username
    end
  end

  #set host location
  def set_host
    @host = 'localhost:3000'
  end

  #set default game image
  def set_game_image
    @game_image = "Text-game-logo.png"
    # set up if statement
  end

  # set a temporary user
  def temp_user
    @recipient = User.find(1)
  end



  # all params
  def game_params
    params.require(:games).permit(:name, :webpage, :category, :creator, :user_id)
  end

  def comment_params
    params.require(:comment).permit(:comment_text, :user_id, :game_id)
  end

  def notification_params
    params.require(:notification).permit(:sender_id, :recipient_id, :notification_type)
  end

  def report_params
    params.require(:report).permit(:reason, :notes, :user_id, :game_id)
  end

  def rating_params
    params.require(:rating).permit(:score, :comment, :user_id, :game_id)
  end

  def subcomment_params
    params.require(:subcomment).permit(:comment_text, :comment_id, :user_id)
  end

  def visit_params
    params.require(:visit).permit(:game_id, :user_id)
  end

end
