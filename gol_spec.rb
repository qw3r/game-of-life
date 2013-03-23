require 'rspec'

class Fixnum

  def rand
    Kernel.rand self
  end

end

# class Cell
#   def initialize(x = nil, y = nil)
#     @x, @y = x, y
#   end

#   def pos
#     [@x,@y]
#   end

#   def neighbours
#     [
#       [x-1,y-1],[x,y-1],[x+1,y-1],
#       [x-1,y],[x+1,y],
#       [x-1,y+1],[x,y+1],[x+1,y+1]
#     ]
#   end
# end

class FiFo < Array
  MAXSIZE = 20
  def push(item)
    self << item
    shift if size > MAXSIZE
  end

  def are_the_same?
    size == MAXSIZE && uniq.size == 1
  end
end

class World < Hash
  attr_accessor :xmax, :xmin, :xmin, :ymin, :iterations, :last_x

  def initialize(count = 0)
    count.times { add_at }
    @xmax = @xmin = @ymax = @ymin = @iterations = 0
    @last_x = FiFo.new
  end

  def cells
    self
  end

  def add_at(x = nil, y = nil)
    x ||= 10.rand
    y ||= 10.rand
    cells.merge!([x,y] => true)
  end

  def kill_at(x,y)
    cells.delete [x,y]
  end

  def cell_is_live?(x,y)
    cells.has_key? [x,y]
  end

  def cell_is_dead?(x,y)
    !cell_is_live?(x,y)
  end

  def cell_will_live?(x,y)
    lns = live_neighbours_of(x,y).size
    if cell_is_live?(x,y)
      lns >= 2 && lns <= 3
    else
      lns == 3
    end
  end

  def cell_will_die?(x,y)
    !cell_will_live?(x,y)
  end

  def iterate!(max_iterations = nil)
    @iterations += 1
    @last_x.push cells.count
    # draw
    puts cells.size
    positions = []
    cells.each do |cell|
      dead_neighbours_of(*cell.first).each { |x,y| positions << [x,y] if cell_will_live?(x,y) }
      positions << cell.first if cell_will_live?(*cell.first)
    end
    cells.clear
    positions.each { |pos| add_at(*pos) }
    # sleep 1
    iterate!(max_iterations) unless (max_iterations && max_iterations <= @iterations) || cells.empty? || finished?
  end

  def neighbours_of(x,y)
    [
      [x-1,y-1],[x,y-1],[x+1,y-1],
      [x-1,y],[x+1,y],
      [x-1,y+1],[x,y+1],[x+1,y+1]
    ]
  end

  def live_neighbours_of(x,y)
    neighbours_of(x,y).select { |x,y| cell_is_live?(x,y) }
  end

  def dead_neighbours_of(x,y)
    neighbours_of(x,y).select { |x,y| cell_is_dead?(x,y) }
  end

  def finished?
    @last_x.are_the_same?
  end

  def draw
    xs = cells.keys.map(&:first)
    ys = cells.keys.map(&:last)

    @xmin, @xmax = [xs.min - 1, @xmin].min, [xs.max + 1, @xmax].max
    @ymin, @ymax = [ys.min - 1, @ymin].min, [ys.max + 1, @ymax].max
    (@ymin..@ymax).each do |y|
      puts
      (xmin..xmax).each do |x|
        chr = case x
              when xmin
                case y
                when @ymin then '┌'
                when @ymax then '└'
                else '│'
                end
              when xmax
                case y
                when @ymin then '┐'
                when @ymax then '┘'
                else '│'
                end
              else
                case y
                when @ymin,@ymax then '─'
                else
                  # print(cell_is_live?(x,y) ? '█' : '░')
                  cell_is_live?(x,y) ? '█' : ' '
                end
              end
        print chr
      end
    end
    puts

  end

end


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
        @w.cell_will_live?(6,4).should == true
      end

    end
  end
end