# frozen_string_literal: true

require 'test_helper'

module Phlex::Stimulus
  module Components
    class TestController < Minitest::Test
      class ShopController < Controller
        self.controller_name = 'shop'

        actions :exit

        action :loadItem do
          param :id
          param :async, optional: true
        end

        targets :button
      end

      context 'actions' do
        context 'on' do
          should 'construct anchor hash without params' do
            actual = ShopController.exit_on('click')
            expected = { action: 'click->shop#exit' }
            assert_equal expected, actual
          end

          should 'construct anchor hash with all params' do
            actual = ShopController.load_item_on('click', id: '25', async: 'true')
            expected = { action: 'click->shop#loadItem', 'shop-id-param' => '25', 'shop-async-param' => 'true' }
            assert_equal expected, actual
          end

          should 'construct anchor hash without optional params' do
            actual = ShopController.load_item_on('click', id: '929')
            expected = { action: 'click->shop#loadItem', 'shop-id-param' => '929' }
            assert_equal expected, actual
          end
        end

        context 'name' do
          should 'return action name' do
            assert_equal 'shop#loadItem', ShopController.load_item_action
          end
        end
      end

      context 'targets' do
        context 'anchor' do
          should 'construct anchor hash' do
            actual = ShopController.button_target_anchor
            expected = { 'shop-target' => 'button' }
            assert_equal expected, actual
          end
        end

        context 'name' do
          should 'return target name' do
            assert_equal 'button', ShopController.button_target
          end
        end

        context 'key' do
          should 'return target key' do
            assert_equal 'shop-target', ShopController.target_key
          end
        end
      end

      context 'params' do
        should 'construct a param name' do
          assert_equal 'shop-description-param', ShopController.param('description')
        end
      end

      context 'dispatched' do
        should 'construct a dispatched event name' do
          assert_equal 'shop:done', ShopController.dispatched('done')
        end
      end

    end
  end
end
