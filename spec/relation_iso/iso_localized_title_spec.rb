RSpec.describe RelatonIso::IsoLocalizedTitle do
  context "instance" do
    subject do
      RelatonIso::IsoLocalizedTitle.new(
        title_intro: "intro", title_main: "main", title_part: "part",
        language: "en", script: "Latn"
      )
    end

    it "returns string" do
      expect(subject.to_s).to eq "intro -- main -- part"
    end
  end
end
