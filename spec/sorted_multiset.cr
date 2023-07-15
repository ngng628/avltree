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

  describe "#count" do
    it "count" do
      s1 = AVLTree::SortedMultiset(Int32){3, 1, 4, 1, 5, 9}
      s1.count(0).should eq 0
      s1.count(1).should eq 2
      s1.count(2).should eq 0
      s1.count(3).should eq 1

      s2 = AVLTree::SortedMultiset(Int32).new
      n = 10**5
      n.times { |i| s2 << i << n - i - 1 }
      n.times do |i|
        s2.count(i).should eq 2
        s2.delete(i)
        s2.count(i).should eq 1
        s2.delete(i)
        s2.count(i).should eq 0
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
