class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  helper_method :current_coder
  # Demo identity: a coder name kept in the session so review actions carry an actor.
  def current_coder = session[:coder].presence || "coder-#{request.remote_ip.to_s.tr('.:', '')[-4..]}"
end
