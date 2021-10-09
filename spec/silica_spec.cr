require "./spec_helper"

describe Silica do
  # Check if generated headers are able to compile as a part of example project
  it "works" do
    Silica::Generator.new(nil, SilicaCore::CppGenerator, "example", "example/silica.json", nil, false).run!
    Dir.cd "example" do
      system "platformio run"
      $?.exit_status.should eq(0)
    end
  end
end
