require "yaml"
require "jing"

RSpec.describe RelatonIsoBib::HashConverter do
  it "creates IsoBibliographicItem form hash" do
    hash = YAML.load_file "spec/examples/iso_bib_item.yml"
    item_hash = RelatonIsoBib::HashConverter.hash_to_bib hash
    item = RelatonIsoBib::IsoBibliographicItem.new(**item_hash)
    xml = item.to_xml(bibdata: true).sub %r{(?<=<fetched>)\d{4}-\d{2}-\d{2}}, Date.today.to_s
    file = "spec/examples/from_yaml.xml"
    File.write file, xml, encoding: "UTF-8" unless File.exist? file
    expect(xml).to be_equivalent_to File.read(file, encoding: "UTF-8")
      .sub %r{(?<=<fetched>)\d{4}-\d{2}-\d{2}}, Date.today.to_s
    # @TODO: schema validation is not working properly until mdoel is updated
    # schema = Jing.new "grammars/relaton-iso-compile.rng"
    # errors = schema.validate file
    # expect(errors).to eq []
  end
end
