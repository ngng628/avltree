require "spec"
require "../src/avltree/sorted_set"

describe AVLTree::SortedSet do
  describe "#includes?" do
    it "includes?" do
      set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      set.includes?(0).should eq false
      set.includes?(1).should eq true
      set.includes?(2).should eq false
      set.includes?(3).should eq true
    end
  end

  describe "#lower_bound" do
    it "lower_bound" do
      set = AVLTree::SortedSet(String){"A", "B", "B", "C", "E"}
      set.lower_bound("@").should eq 0
      set.lower_bound("A").should eq 0
      set.lower_bound("B").should eq 1
      set.lower_bound("C").should eq 2
      set.lower_bound("D").should eq 3
      set.lower_bound("E").should eq 3
      set.lower_bound("F").should eq 4
      set.lower_bound("Z").should eq 4
    end
  end

  describe "#upper_bound" do
    it "upper_bound" do
      set = AVLTree::SortedSet(String){"A", "B", "B", "C", "E"}
      set.upper_bound("@").should eq 0
      set.upper_bound("A").should eq 1
      set.upper_bound("B").should eq 2
      set.upper_bound("C").should eq 3
      set.upper_bound("D").should eq 3
      set.upper_bound("E").should eq 4
      set.upper_bound("F").should eq 4
      set.upper_bound("Z").should eq 4
    end
  end

  describe "#less_object_with_index" do
    it "less_object_with_index" do
      set = AVLTree::SortedSet(String){"A", "B", "B", "C", "E"}
      set.less_object_with_index("@").should eq({nil, nil})
      set.less_object_with_index("A").should eq({nil, nil})
      set.less_object_with_index("B").should eq({"A", 0})
      set.less_object_with_index("C").should eq({"B", 1})
      set.less_object_with_index("D").should eq({"C", 2})
      set.less_object_with_index("E").should eq({"C", 2})
      set.less_object_with_index("F").should eq({"E", 3})
      set.less_object_with_index("Z").should eq({"E", 3})
    end
  end

  describe "#less_equal_object_with_index" do
    it "less_equal_object_with_index" do
      set = AVLTree::SortedSet(String){"A", "B", "B", "C", "E"}
      set.less_equal_object_with_index("@").should eq({nil, nil})
      set.less_equal_object_with_index("A").should eq({"A", 0})
      set.less_equal_object_with_index("B").should eq({"B", 1})
      set.less_equal_object_with_index("C").should eq({"C", 2})
      set.less_equal_object_with_index("D").should eq({"C", 2})
      set.less_equal_object_with_index("E").should eq({"E", 3})
      set.less_equal_object_with_index("F").should eq({"E", 3})
      set.less_equal_object_with_index("Z").should eq({"E", 3})
    end
  end

  describe "#greater_object_with_index" do
    it "greater_object_with_index" do
      set = AVLTree::SortedSet(String){"A", "B", "B", "C", "E"}
      set.greater_object_with_index("@").should eq({"A", 0})
      set.greater_object_with_index("A").should eq({"B", 1})
      set.greater_object_with_index("B").should eq({"C", 2})
      set.greater_object_with_index("C").should eq({"E", 3})
      set.greater_object_with_index("D").should eq({"E", 3})
      set.greater_object_with_index("E").should eq({nil, nil})
      set.greater_object_with_index("F").should eq({nil, nil})
      set.greater_object_with_index("Z").should eq({nil, nil})
    end
  end

  describe "#greater_equal_object_with_index" do
    it "greater_equal_object_with_index" do
      set = AVLTree::SortedSet(String){"A", "B", "B", "C", "E"}
      set.greater_equal_object_with_index("@").should eq({"A", 0})
      set.greater_equal_object_with_index("A").should eq({"A", 0})
      set.greater_equal_object_with_index("B").should eq({"B", 1})
      set.greater_equal_object_with_index("C").should eq({"C", 2})
      set.greater_equal_object_with_index("D").should eq({"E", 3})
      set.greater_equal_object_with_index("E").should eq({"E", 3})
      set.greater_equal_object_with_index("F").should eq({nil, nil})
      set.greater_equal_object_with_index("Z").should eq({nil, nil})
    end
  end

  describe "#greater_equal_object" do
    it "greater_equal_object_with_index" do
      set = AVLTree::SortedSet(String){"A", "B", "B", "C", "E"}
      set.greater_equal_object("@").should eq("A")
      set.greater_equal_object("A").should eq("A")
      set.greater_equal_object("B").should eq("B")
      set.greater_equal_object("C").should eq("C")
      set.greater_equal_object("D").should eq("E")
      set.greater_equal_object("E").should eq("E")
      set.greater_equal_object("F").should eq(nil)
      set.greater_equal_object("Z").should eq(nil)
    end
  end

  describe "#greater_equal_index" do
    it "greater_equal_index" do
      set = AVLTree::SortedSet(String){"A", "B", "B", "C", "E"}
      set.greater_equal_index("@").should eq(0)
      set.greater_equal_index("A").should eq(0)
      set.greater_equal_index("B").should eq(1)
      set.greater_equal_index("C").should eq(2)
      set.greater_equal_index("D").should eq(3)
      set.greater_equal_index("E").should eq(3)
      set.greater_equal_index("F").should eq(nil)
      set.greater_equal_index("Z").should eq(nil)
    end
  end

  describe "#index" do
    it "index" do
      set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      set.index(0).should eq nil
      set.index(1).should eq 0
      set.index(2).should eq nil
      set.index(3).should eq 1
    end
  end

  describe "#concat" do
    it "concat" do
      set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      other = AVLTree::SortedSet(Int32){1, 4, 1, 4, 2}
      set.concat(other).should eq AVLTree::SortedSet{1, 2, 3, 4, 5, 9}
    end
  end

  describe "#to_s" do
    it "to_s" do
      set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      set.to_s.should eq "SortedSet{1, 3, 4, 5, 9}"
    end
  end

  describe "#to_s" do
    it "to_s" do
      set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      set.to_a.should eq [1, 3, 4, 5, 9]
    end
  end

  describe "#to_sorted_set" do
    it "to_s" do
      set = Set(Int32){3, 1, 4, 1, 5, 9}
      sorted_set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      set.to_sorted_set.should eq sorted_set
    end
  end
end
