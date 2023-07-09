require "spec"

require "../src/sorted_multiset"

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
      set = AVLTree::SortedMultiset(Int32){3, 1, 4, 1, 5, 9}
      set.count(0).should eq 0
      set.count(1).should eq 2
      set.count(2).should eq 0
      set.count(3).should eq 1
    end
  end

  describe "#concat" do
    it "concat" do
      set = AVLTree::SortedMultiset(Int32){3, 1, 4, 1, 5, 9}
      other = AVLTree::SortedMultiset(Int32){1, 4, 1, 4, 2}
      set.concat(other).should eq AVLTree::SortedMultiset{3, 1, 4, 1, 5, 9, 1, 4, 1, 4, 2}
    end
  end

  describe "#concat" do
    it "concat" do
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