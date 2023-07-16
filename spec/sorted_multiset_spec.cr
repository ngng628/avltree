require "spec"

require "../src/avltree/sorted_multiset"

describe AVLTree::SortedMultiset do
  describe "#includes?" do
    it "includes?" do
      set = AVLTree::SortedMultiset(Int32){3, 1, 4, 1, 5, 9}
      set.includes?(0).should eq false
      set.includes?(1).should eq true
      set.includes?(2).should eq false
      set.includes?(3).should eq true
    end
  end

  describe "#fetch(index : Int, &)" do
    it "fetch" do
      set = AVLTree::SortedMultiset(Int32){3, 1, 4, 1, 5, 9}
      set.fetch(-7) { |i| i }.should eq -7
      set.fetch(-6) { |i| i }.should eq 1
      set.fetch(-5) { |i| i }.should eq 1
      set.fetch(-4) { |i| i }.should eq 3
      set.fetch(-3) { |i| i }.should eq 4
      set.fetch(-2) { |i| i }.should eq 5
      set.fetch(-1) { |i| i }.should eq 9
      set.fetch(0) { |i| i }.should eq 1
      set.fetch(1) { |i| i }.should eq 1
      set.fetch(2) { |i| i }.should eq 3
      set.fetch(3) { |i| i }.should eq 4
      set.fetch(4) { |i| i }.should eq 5
      set.fetch(5) { |i| i }.should eq 9
      set.fetch(6) { |i| i }.should eq 6
    end
  end

  describe "#fetch(index : Int, default)" do
    it "fetch" do
      set = AVLTree::SortedMultiset(Int32){3, 1, 4, 1, 5, 9}
      set.fetch(-7, nil).should eq nil
      set.fetch(-6, nil).should eq 1
      set.fetch(-5, nil).should eq 1
      set.fetch(-4, nil).should eq 3
      set.fetch(-3, nil).should eq 4
      set.fetch(-2, nil).should eq 5
      set.fetch(-1, nil).should eq 9
      set.fetch(0, nil).should eq 1
      set.fetch(1, nil).should eq 1
      set.fetch(2, nil).should eq 3
      set.fetch(3, nil).should eq 4
      set.fetch(4, nil).should eq 5
      set.fetch(5, nil).should eq 9
      set.fetch(6, nil).should eq nil
    end
  end

  describe "#count" do
    it "count" do
      s1 = AVLTree::SortedMultiset(Int32){3, 1, 4, 1, 5, 9}
      s1.count(0).should eq 0
      s1.count(1).should eq 2
      s1.count(2).should eq 0
      s1.count(3).should eq 1

      s2 = AVLTree::SortedMultiset(Int32).new
      n = 10**5
      5.times { n.times { |i| s2 << i << n - i - 1 } }
      n.times do |i|
        10.downto(0) do |cnt|
          s2.count(i).should eq cnt
          s2.delete(i)
        end
      end
    end
  end

  describe "#count" do
    it "count" do
      s1 = AVLTree::SortedMultiset(Int32){3, 1, 4, 1, 5, 9}
      s1.count(0..1).should eq 2
      s1.count(0...1).should eq 0
      s1.count(0..2).should eq 2
      s1.count(0...2).should eq 2
      s1.count(2..3).should eq 1
      s1.count(2...3).should eq 0
      s1.count(2..9).should eq 4
      s1.count(2...9).should eq 3
      s1.count(2...).should eq 4
      s1.count(...).should eq 6
      s1.count(...9).should eq 5

      s2 = AVLTree::SortedMultiset(String){"C", "A", "D", "A", "E", "I"}
      s2.count("@".."A").should eq 2
      s2.count("@"..."A").should eq 0
      s2.count("@".."B").should eq 2
      s2.count("@"..."B").should eq 2
      s2.count("B".."C").should eq 1
      s2.count("B"..."C").should eq 0
      s2.count("B".."I").should eq 4
      s2.count("B"..."I").should eq 3
      s2.count("B"...).should eq 4
      s2.count(...).should eq 6
      s2.count(..."I").should eq 5
    end
  end

  describe "#delete_at" do
    it "delete at" do
      set = AVLTree::SortedMultiset(Int32){3, 1, 4, 1, 5, 9}
      set.to_a.should eq [1, 1, 3, 4, 5, 9]
      set.delete_at(3)
      set.to_a.should eq [1, 1, 3, 5, 9]
      set.delete_at(3)
      set.to_a.should eq [1, 1, 3, 9]
      set.delete_at(2)
      set.to_a.should eq [1, 1, 9]
      set.delete_at(1)
      set.to_a.should eq [1, 9]
      set.delete_at(0)
      set.to_a.should eq [9]
      set.delete_at(0)
      set.to_a.should eq [] of Int32
    end
  end

  describe "#shift" do
    it "shift" do
      n = 10**5
      ary = [] of Int32
      2.times { n.times { |i| ary << i << i + n << i + 2*n } }
      set = AVLTree::SortedMultiset(Int32).new(ary)
      ary.sort!.reverse!
      (3*n).times do
        set.shift.should eq ary.pop
      end
    end
  end

  describe "#pop" do
    it "pop" do
      n = 10**5
      ary = [] of Int32
      2.times { n.times { |i| ary << i << i + n << i + 2*n } }
      set = AVLTree::SortedMultiset(Int32).new(ary)
      ary.sort!
      (3*n).times do
        set.pop.should eq ary.pop
      end
    end
  end

  describe "#index" do
    it "index" do
      set = AVLTree::SortedMultiset(Int32){3, 1, 4, 1, 5, 9}
      set.index(0).should eq nil
      set.index(1).should eq 0
      set.index(2).should eq nil
      set.index(3).should eq 2
    end
  end

  describe "#rindex" do
    it "rindex" do
      set = AVLTree::SortedMultiset(Int32){3, 1, 4, 1, 5, 9}
      set.rindex(0).should eq nil
      set.rindex(1).should eq 1
      set.rindex(2).should eq nil
      set.rindex(3).should eq 2
    end
  end

  describe "#concat" do
    it "concat" do
      set = AVLTree::SortedMultiset(Int32){3, 1, 4, 1, 5, 9}
      other = AVLTree::SortedMultiset(Int32){1, 4, 1, 4, 2}
      set.concat(other).should eq AVLTree::SortedMultiset{3, 1, 4, 1, 5, 9, 1, 4, 1, 4, 2}
    end
  end

  describe "#to_a" do
    it "to_a" do
      set = AVLTree::SortedMultiset(Int32){3, 1, 4, 1, 5, 9}
      set.to_a.should eq [1, 1, 3, 4, 5, 9]
    end
  end

  describe "#to_s" do
    it "to_s" do
      set = AVLTree::SortedMultiset(Int32){3, 1, 4, 1, 5, 9}
      set.to_s.should eq "SortedMultiset{1, 1, 3, 4, 5, 9}"
    end
  end
end
