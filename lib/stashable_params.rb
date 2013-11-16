require "stashable_params/version"

module StashableParams
  def stash_params
    session[:stashed_params] = filter_params(params, params_filter)
  end

  def unstash_params
    params.merge!(session.delete(:stashed_params)) if session[:stashed_params]
  end

  def filter_params(hash, filter)
    filtered_hash = hash
    filtered_hash.each do |k, v|
      if filter.include?(k) || filter.include?(k.to_sym)
        filtered_hash.delete(k)
      else
        filter_params(v, filter) if v.is_a?(Hash)
      end
    end
    filtered_hash
  end

  def params_filter
    [:password, :password_confirmation, :action, :controller]
  end
end
