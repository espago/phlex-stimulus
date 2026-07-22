# frozen_string_literal: true

require 'test_helper'

class Phlex::TestStimulus < Minitest::Test
  should 'have a version number' do
    refute_nil ::Phlex::Stimulus::VERSION
  end
end
