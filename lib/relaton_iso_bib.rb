require "nokogiri"
require "isoics"
require "relaton_bib"
require "relaton_iso_bib/version"
require "relaton_iso_bib/util"
require "relaton_iso_bib/document_type"
require "relaton_iso_bib/iso_bibliographic_item"
require "digest/md5"

module RelatonIsoBib
  class Error < StandardError; end

  # Returns hash of XML reammar
  # @return [String]
  def self.grammar_hash
    # gem_path = File.expand_path "..", __dir__
    # grammars_path = File.join gem_path, "grammars", "*"
    # grammars = Dir[grammars_path].sort.map { |gp| File.read gp, encoding: "UTF-8" }.join
    Digest::MD5.hexdigest RelatonIsoBib::VERSION + RelatonBib::VERSION # grammars
  end
end
