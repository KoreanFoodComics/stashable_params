require "stashable_params/version"

module StashableParams
  def stash_params
    session[:stashed_params] = params
  end
end
