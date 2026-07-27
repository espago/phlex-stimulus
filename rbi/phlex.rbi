# typed: true

class Phlex::HTML < Phlex::SGML
  include ActionView::Helpers::AssetUrlHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::NumberHelper

  sig { params(key: T.untyped, options: T.untyped).returns(String) }
  def t(key, **options); end

  def label(**attributes); end

  def form_authenticity_token(*_arg0, **_arg1, &_arg2); end

  sig { returns(ApplicationController::HelperProxy) }
  def view_context; end

  # Outputs an `<svg>` tag.
  #
  # [MDN Docs](https://developer.mozilla.org/docs/Web/SVG/Element/svg)
  # [Spec](https://html.spec.whatwg.org/#the-svg-element)
  #
  # source://phlex//lib/phlex/html.rb#20
  #
  #: (*untyped, **String) ?{ (Phlex::SVG) -> void } -> void
  def svg(*args, **attrs, &block); end
end

class Phlex::SGML
  #: (String?) -> void
  def plain(content); end

  #: (String?) -> void
  def raw(content); end
end

module Phlex::Rails::Helpers::Translate
  sig { params(key: String, _arg1: T.anything).returns(String) }
  def t(key, **_arg1); end
end
