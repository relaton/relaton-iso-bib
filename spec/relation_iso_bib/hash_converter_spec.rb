require "yaml"

RSpec.describe RelatonIsoBib::HashConverter do
  it "creates IsoBibliographicItem form hash" do
    hash = YAML.load_file "spec/examples/iso_bib_item.yml"
    item_hash = RelatonIsoBib::HashConverter.hash_to_bib hash
    item = RelatonIsoBib::IsoBibliographicItem.new item_hash
    xml = item.to_xml bibdata: true
    file = "spec/examples/from_yaml.xml"
    File.write file, xml, encoding: "UTF-8" unless File.exist? file
    expect(xml).to be_equivalent_to File.read(file, encoding: "UTF-8").
      sub %r{(?<=<fetched>)\d{4}-\d{2}-\d{2}}, Date.today.to_s
  end

  context "split title into" do
    it "0 parts" do
      title = RelatonIsoBib::HashConverter.split_title ""
      expect(title).to include(title_intro: nil, title_main: "", title_part: nil)
    end

    context "2 parts" do
      it "with title part" do
        title = RelatonIsoBib::HashConverter.split_title "Main -- Part 1:"
        expect(title).to include(title_intro: nil, title_main: "Main", title_part: "Part 1:")
      end

      it "without title part" do
        title = RelatonIsoBib::HashConverter.split_title "Intro -- Main"
        expect(title).to include(title_intro: "Intro", title_main: "Main", title_part: nil)
      end
    end

    it "3 parts" do
      title = RelatonIsoBib::HashConverter.split_title "Intro -- Main -- Part"
      expect(title).to include(title_intro: "Intro", title_main: "Main", title_part: "Part")
    end

    it "more than 3 parts" do
      title = RelatonIsoBib::HashConverter.split_title "Intro -- Main -- Part -- More"
      expect(title).to include(title_intro: "Intro", title_main: "Main", title_part: "Part -- More")
    end
  end
end
