require 'spec_helper'

describe 'Game of Life' do

  describe World do
    it { should respond_to :cells }
    its(:cells) { should be_empty }

    it 'should init with random number of cells' do
      World.new(3).cells.size.should == 3
    end

    it "can tell if a position is live or died" do
      w = World.new
      w.add_at 5,5
      w.cell_is_live?(5,5).should == true
      w.cell_is_live?(4,5).should == false
    end


    describe "can tell if a cell will liveor die" do
      before :all do
        @w = World.new
        @w.add_at 3, 3
        @w.add_at 4, 5
        @w.add_at 5, 4
        @w.add_at 5, 5
        @w.add_at 5, 6
        @w.add_at 6, 6
      end

      it 'cell should live' do
        @w.cell_will_live?(5,6).should == true
      end

      it 'cell should die due to under population (< 2)' do
        @w.cell_will_die?(3,3).should == true
      end

      it 'cell should die due to over population (> 3)' do
        @w.cell_will_die?(5,5).should == true
      end

      it 'cell should born due to reproduction (= 3)' do
        @w.cell_will_live?(6,4).should == false
      end

    end
  end
end
