require 'test_helper'
require 'byebug'

class ApplicationController
  include StashableParams
  class << self; attr_accessor :session end
  attr_accessor :params

  @@session = {}

  def initialize
    @params  = {}
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

class TestController < ApplicationController
  def session
    self.class.session
  end

  def stash_params_action
    stash_params
  end
end

describe TestController do
  let(:params) { { test: 'params', password: 'password', other_param: 'save me!', sensitive_param: 'dont save me!' } }
  let(:test_controller) { TestController.new }

  it 'can stash params' do
    test_controller.params = params
    test_controller.params.must_equal(params)

    test_controller.stash_params_action
    ApplicationController.session[:stashed_params].must_equal params
  end
end
