# frozen_string_literal: true

require 'test_helper'

class Phlex::On::TestSorbet < Minitest::Test
  should 'have a version number' do
    refute_nil ::Phlex::On::Sorbet::VERSION
  end
end
