# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include ApplicationHelper # this is still necessary
  include CASControllerIncludes
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :set_current_user
  before_filter :set_actionmailer_base_url

  # rescue_from Exception do |e|
  #   @exception = e
  #   render 'common/exception', :status => 500

  # Redirects with a flash[:notice] if condition is true, and returns true.
  #
  # Usage: return if redirect_if(!user_logged_in, "Not logged in!", "/diaf")
  #
  def redirect_if(condition=true, error_msg='Error!', redirect_url=nil)
    return false if !condition || redirect_url.nil?
    flash[:error] = error_msg
    redirect_to redirect_url
    true
  end



####################
#     FILTERS      #
####################

  # Used by both ApplicsController and JobsController
  def job_accessible
    j = (Job.find(params[:job_id].present? ? params[:job_id] : params[:id]) rescue nil)
    if j == nil
      flash[:error] = 'We couldn\'t find that project.'
      redirect_to jobs_path
    end
  end

  # User shouldn't watch or apply to their own job.
  def watch_apply_ok_for_job
    j = (Job.find(params[:job_id].present? ? params[:job_id] : params[:id]) rescue nil)
    if j == nil || @current_user == j.user
      flash[:error] = 'You can\'t watch or apply to your own listing.'
      redirect_to job_path(j)
    end
  end

  # Tests exception notification by raising an uncaught exception.
  def test_exception_notification
    raise NotImplementedError.new('Exceptions aren\'t implemented yet.')
  end

  private

  def set_actionmailer_base_url
    ActionMailer::Base.default_url_options ||= {}
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end

  def set_current_user
    if Rails.env.staging?
      user = User.find_by(:name => 'Beehive Team')
      UserSession.new(user).save
      session[:user_id] = user.id
      flash[:notice] = "Signed in automatically as Beehive Team"
    end
    @user_session = UserSession.find
    @current_user = @user_session.user if @user_session
  end

  def require_admin
    unless logged_in_as_admin?
      redirect_to request.referer || home_path, :notice => "Sorry, you can't access that."
    end
  end

  def remember_location
  session[:back_paths] ||= [dashboard_path]
    unless session[:back_paths].last == request.fullpath
      session[:back_paths] << request.fullpath
    end
    session[:back_paths] = session[:back_paths][0..2]
  end

  def back
    session[:back_paths] ||= [dashboard_path]
    session[:back_paths].pop || :back
  end

end
