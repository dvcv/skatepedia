class WikisController < ApplicationController
  before_action :authorize_user, except: [:index, :show, :new, :create, :edit, :update]
  before_action :user_is_authorized_to_edit_private_wiki, only: [:show, :edit, :update]

  def index
    @wikis = policy_scope(Wiki)
  end

  def show
    @wiki = Wiki.find(params[:id])
  end

  def new
    @wiki = Wiki.new
  end

  def create
    @wiki = Wiki.new
    @wiki.title = params[:wiki][:title]
    @wiki.body = params[:wiki][:body]
    @wiki.private = params[:wiki][:private]
    @wiki.user = current_user


    if @wiki.save
      flash[:notice] = "Wiki was saved."
      redirect_to @wiki
    else
      flash.now[:alert] = "There was an error saving the wiki. Please try again."
      render :new
    end
  end

  def edit
    @wiki = Wiki.find(params[:id])
    @users = User.all_except(current_user)
  end
  def update
    @wiki = Wiki.find(params[:id])
    @wiki.title = params[:wiki][:title]
    @wiki.body = params[:wiki][:body]

    #only let premium owner or admin change the private settings and collaborators
    if current_user == @wiki.user || current_user.admin?
      @wiki.private = params[:wiki][:private]
      @wiki.user_ids = params[:collaborators]
    end

    if @wiki.private == false
      @wiki.user_ids = nil
    end

    if @wiki.save
      flash[:notice] = "Wiki was updated."
      redirect_to @wiki
    else
      flash.now[:alert] = "There was an error saving the wiki. Please try again."
      render :edit
    end
  end

  def destroy
    @wiki = Wiki.find(params[:id])

    if @wiki.destroy
     flash[:notice] = "\"#{@wiki.title}\" was deleted successfully."
     redirect_to wikis_path
    else
     flash.now[:alert] = "There was an error deleting the wiki."
     render :show
    end
  end

private
  def authorize_user
    wiki = Wiki.find(params[:id])
    unless current_user == wiki.user || current_user.admin?
      flash[:alert] = "You must be an admin to do that."
      redirect_to wikis_path
    end
  end

  def user_is_authorized_to_edit_private_wiki
    wiki = Wiki.find(params[:id])
    if !(current_user == wiki.user || current_user.admin? || wiki.users.include?(current_user)) && wiki.private == true
      flash[:alert] = "You must be a collaborator to do that."
      redirect_to wikis_path
    end
  end
end
