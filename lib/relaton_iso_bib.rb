require "relaton_iso_bib/version"
require "relaton_iso_bib/iso_bibliographic_item"
require "digest/md5"

module RelatonIsoBib
  class Error < StandardError; end

  # Returns hash of XML reammar
  def self.grammar_hash
    gem_path = File.expand_path "..", __dir__
    grammars_path = File.join gem_path, "grammars", "*"
    grammars = Dir[grammars_path].map { |gp| File.read gp }.join
    Digest::MD5.hexdigest grammars
  end
end
