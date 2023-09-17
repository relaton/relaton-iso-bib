module RelatonIsoBib
  module Util
    extend RelatonBib::Util

    def self.logger
      RelatonIsoBib.configuration.logger
    end
  end
end
