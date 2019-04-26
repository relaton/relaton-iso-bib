RSpec.describe RelatonIso::Ics do
  it "raises error when there is no ICS code and field" do
    expect { RelatonIso::Ics.new }.to raise_error ArgumentError
  end
end
