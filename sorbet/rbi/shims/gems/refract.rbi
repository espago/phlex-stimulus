# typed: true

class ApplicationController
  module HelperProxy
    sig { params(path: String).returns(T.nilable(String))}
    def resolve_asset_path(path); end
  end
end

module Refract
  class Visitor; end
  class MutationVisitor; end
end
