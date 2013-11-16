require 'test_helper'
require 'byebug'

class ApplicationController
  class << self; attr_accessor :session end
  attr_accessor :params

  @@session = {}      # Mimics session available from all controllers in rails app

  def initialize
    @params  = {}     # Mimics params hash available within controllers in rails app
  end

  def session
    # Gives easy access to the session to class instances
    self.class.session
  end

  def self.session
    @@session
  end

  def self.session=(hash)
    @@session = hash
  end
end

describe ApplicationController do
  it 'has access to a session and params hash' do
    ApplicationController.session.wont_equal nil
    ApplicationController.new.params.wont_equal nil
  end
end

class StashableController < ApplicationController
  include StashableParams

  def stash_params_action
    stash_params
  end

  def unstash_params_action
    unstash_params
  end

  def self.reset_default_params_filter
    def params_filter
      [:password, :password_confirmation, :action, :controller]
    end
  end
end

describe StashableController do
  let(:params) { { normal_param_key: 'params',
                   password: 'password',
                   sensitive_param: 'dont save me!',
                   nested_hash: { nested_key: "I'm nested!" } } }

  let(:stashable_controller) { StashableController.new }

  it 'can stash params' do
    stashable_controller.params = params

    stashable_controller.stash_params_action
    ApplicationController.session[:stashed_params].must_equal params
  end

  it 'can unstash params' do
    stashable_controller.params = params
    stashable_controller.stash_params_action
    stashable_controller.params.must_equal(params)
    stashable_controller.params = {}
    stashable_controller.params.must_equal({})

    stashable_controller.unstash_params_action

    ApplicationController.session[:stashed_params].must_equal {}
    stashable_controller.params.must_equal(params)
  end

  it 'provides a default filter for filtering out sensitive params' do
    stashable_controller.params = params
    stashable_controller.stash_params_action

    ApplicationController.session[:stashed_params].wont_include(:password)
    ApplicationController.session[:stashed_params].must_include(:normal_param_key)
  end

  it 'can redefine the filter to omit additional params' do
    class StashableController < ApplicationController
      def params_filter
        [:sensitive_param]
      end
    end

    stashable_controller.params = params
    stashable_controller.stash_params_action

    ApplicationController.session[:stashed_params].wont_include(:sensitive_param)
    StashableController.reset_default_params_filter
  end

  it 'filters nested parameter keys' do
    class StashableController < ApplicationController
      def params_filter
        [:nested_key]
      end
    end

    stashable_controller.params = params
    stashable_controller.stash_params_action

    ApplicationController.session[:stashed_params][:nested_hash].wont_include(:nested_key)
    StashableController.reset_default_params_filter
  end
end
