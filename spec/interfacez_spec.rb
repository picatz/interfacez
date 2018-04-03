RSpec.describe Interfacez do
  it "has a version number" do
    expect(Interfacez::VERSION).not_to be nil
  end

  it "has a default method" do
    expect(Interfacez.default).to be
  end
  
  it "has a loopback method" do
    expect(Interfacez.loopback).to be
  end
end
