class ApplicationController < ActionController::Base

  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_forbidden
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_action :default_format_json
  before_action :authenticate
  before_action :current_user

  protected
  def authenticate
    authenticate_basic_auth || render_unauthorized
  end

  def authenticate_basic_auth
    authenticate_with_http_basic do |name, password|
      return false if User.where(name: name).blank?
      local_user = User.find_by(name: name)
      @current_user = local_user if local_user.authenticate(password)
      local_user.authenticate(password)
    end
  end

  def default_format_json
    request.format = :json
  end

  def current_user
    @current_user ||= nil
  end

  def render_unauthorized
    self.headers['WWW-Authenticate'] = 'Token realm="Application"'
    render json: 'Bad credentials', status: :unauthorized
  end

  def user_forbidden
    render json: 'Forbidden for this user', status: :forbidden
  end
end
