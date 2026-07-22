# frozen_string_literal: true

require_relative 'sorbet/version'

require 'rails'
require 'phlex'
require 'phlex/rails'
require 'booleans'

module Phlex
  module On
    module Sorbet
    end
  end
end

require_relative 'sorbet/components'
