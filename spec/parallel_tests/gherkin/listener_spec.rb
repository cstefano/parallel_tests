require 'parallel_tests/gherkin/listener'

describe ParallelTests::Gherkin::Listener do
  describe :collect do
    before(:each) do
      @listener = ParallelTests::Gherkin::Listener.new
      @listener.uri("feature_file")
    end

    it "returns steps count" do
      3.times {@listener.step(nil)}
      expect(@listener.collect).to eq({"feature_file" => 3})
    end

    it "counts background steps separately" do
      @listener.background("background")
      5.times {@listener.step(nil)}
      expect(@listener.collect).to eq({"feature_file" => 0})

      @listener.scenario("scenario")
      2.times {@listener.step(nil)}
      expect(@listener.collect).to eq({"feature_file" => 2})

      @listener.scenario("scenario")
      expect(@listener.collect).to eq({"feature_file" => 2})

      @listener.eof
      expect(@listener.collect).to eq({"feature_file" => 12})
    end

    it "counts scenario outlines steps separately" do
      @listener.scenario_outline("outline")
      5.times {@listener.step(nil)}
      @listener.examples(double('examples', :rows => Array.new(3)))
      expect(@listener.collect).to eq({"feature_file" => 15})

      @listener.scenario("scenario")
      2.times {@listener.step(nil)}
      expect(@listener.collect).to eq({"feature_file" => 17})

      @listener.scenario("scenario")
      expect(@listener.collect).to eq({"feature_file" => 17})

      @listener.eof
      expect(@listener.collect).to eq({"feature_file" => 17})
    end

    it 'counts scenarios that should not be ignored' do
      @listener.ignore_tag_pattern = nil
      @listener.scenario( double('scenario', :tags =>[ double('tag', :name => '@WIP' )]) )
      @listener.step(nil)
      @listener.eof
      expect(@listener.collect).to eq({"feature_file" => 1})

      @listener.ignore_tag_pattern = /@something_other_than_WIP/
      @listener.scenario( double('scenario', :tags =>[ double('tag', :name => '@WIP' )]) )
      @listener.step(nil)
      @listener.eof
      expect(@listener.collect).to eq({"feature_file" => 2})
    end

    it 'does not count scenarios that should be ignored' do
      @listener.ignore_tag_pattern = /@WIP/
      @listener.scenario( double('scenario', :tags =>[ double('tag', :name => '@WIP' )]))
      @listener.step(nil)
      @listener.eof
      expect(@listener.collect).to eq({"feature_file" => 0})
    end

    it 'counts outlines that should not be ignored' do
      @listener.ignore_tag_pattern = nil
      @listener.scenario_outline( double('scenario', :tags =>[ double('tag', :name => '@WIP' )]) )
      @listener.step(nil)
      @listener.examples(double('examples', :rows => Array.new(3)))
      @listener.eof
      expect(@listener.collect).to eq({"feature_file" => 3})

      @listener.ignore_tag_pattern = /@something_other_than_WIP/
      @listener.scenario_outline( double('scenario', :tags =>[ double('tag', :name => '@WIP' )]) )
      @listener.step(nil)
      @listener.examples(double('examples', :rows => Array.new(3)))
      @listener.eof
      expect(@listener.collect).to eq({"feature_file" => 6})
    end

    it 'does not count outlines that should be ignored' do
      @listener.ignore_tag_pattern = /@WIP/
      @listener.scenario_outline( double('scenario', :tags =>[ double('tag', :name => '@WIP' )]) )
      @listener.step(nil)
      @listener.examples(double('examples', :rows => Array.new(3)))
      @listener.eof
      expect(@listener.collect).to eq({"feature_file" => 0})
    end

  end
end
