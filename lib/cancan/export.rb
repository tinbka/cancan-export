require "cancan"
require "gon"

require "cancan/export/version"
require "cancan/export/compiler"
require "cancan/export/helpers"
require "cancan/export/engine"
require "cancan/export/ext/ability"
require "cancan/export/ext/rule"

module CanCan
  class Rule
    include Export::Rule
  end
  
  module Ability
    include Export::Ability
  end
  
  module Export
    ::ActionController::Base.send :include, ControllerHelpers
  end
end
