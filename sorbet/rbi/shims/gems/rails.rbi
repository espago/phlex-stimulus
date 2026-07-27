# typed: true

module Zeitwerk
  class GemLoader; end
  class Loader; end
end

module Mail
  class Message; end
end

module ActionMailer
  class Collector
  end
end

module ActiveJob
  module Exceptions
    JITTER_DEFAULT = 5
  end
end

module ActiveJob
  module Continuation
    class Step
    end
  end
end

module ActiveModel
  class Error; end
end

module ActiveRecord
  module ConnectionAdapters
    module SchemaStatements; end
    module DatabaseStatements; end
  end
end

class SignedGlobalID; end

module Rails
  module Generators
    class Base; end
    class NamedBase < Base; end
  end
end
