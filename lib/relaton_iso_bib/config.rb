module RelatonIsoBib
  module Config
    include RelatonBib::Config
  end
  extend Config

  class Configuration < RelatonBib::Configuration
    PROGNAME = "relaton-iso-bib".freeze
  end
end
