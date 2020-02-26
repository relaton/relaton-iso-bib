RSpec.describe RelatonIsoBib::XMLParser do
  it "creates item form xml" do
    xml = File.read "spec/examples/iso_bib_item.xml", encoding: "UTF-8"
    item = RelatonIsoBib::XMLParser.from_xml xml
    expect(item.to_xml(bibdata: true)).to be_equivalent_to xml
  end

  it "warn if XML doesn't have bibitem or bibdata element" do
    item = ""
    expect { item = RelatonIsoBib::XMLParser.from_xml "" }.to output(/can't find bibitem/)
      .to_stderr
    expect(item).to be_nil
  end
end
