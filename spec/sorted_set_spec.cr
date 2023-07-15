require "spec"
require "../src/avltree/sorted_set"

describe AVLTree::SortedSet do
  describe "#includes?" do
    it "includes?" do
      s1 = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      s1.includes?(0).should eq false
      s1.includes?(1).should eq true
      s1.includes?(2).should eq false
      s1.includes?(3).should eq true

      n = 10**5
      s2 = AVLTree::SortedSet(Int32).new
      n.times { |i| s2 << i << i + n << i + 2*n }
      (3*n).times do |i|
        s2.includes?(i).should eq true
        s2.delete i
      end
    end
  end

  describe "#fetch(index : Int, &)" do
    it "fetch" do
      set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      set.fetch(-6) { |i| i }.should eq -6
      set.fetch(-5) { |i| i }.should eq 1
      set.fetch(-4) { |i| i }.should eq 3
      set.fetch(-3) { |i| i }.should eq 4
      set.fetch(-2) { |i| i }.should eq 5
      set.fetch(-1) { |i| i }.should eq 9
      set.fetch(0) { |i| i }.should eq 1
      set.fetch(1) { |i| i }.should eq 3
      set.fetch(2) { |i| i }.should eq 4
      set.fetch(3) { |i| i }.should eq 5
      set.fetch(4) { |i| i }.should eq 9
      set.fetch(5) { |i| i }.should eq 5
    end
  end

  describe "#fetch(index : Int, default)" do
    it "fetch" do
      set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      set.fetch(-6, nil).should eq nil
      set.fetch(-5, nil).should eq 1
      set.fetch(-4, nil).should eq 3
      set.fetch(-3, nil).should eq 4
      set.fetch(-2, nil).should eq 5
      set.fetch(-1, nil).should eq 9
      set.fetch(0, nil).should eq 1
      set.fetch(1, nil).should eq 3
      set.fetch(2, nil).should eq 4
      set.fetch(3, nil).should eq 5
      set.fetch(4, nil).should eq 9
      set.fetch(5, nil).should eq nil
    end
  end

  describe "#count" do
    it "count" do
      s1 = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      s1.count(0).should eq 0
      s1.count(1).should eq 1
      s1.count(2).should eq 0
      s1.count(3).should eq 1
      s1.count(4).should eq 1

      s2 = AVLTree::SortedSet(Int32).new
      n = 10**5
      n.times { |i| s2 << i << n - i - 1 }
      n.times do |i|
        s2.count(i).should eq 1
        s2.delete(i)
        s2.count(i).should eq 0
      end
    end
  end

  describe "#min" do
    it "returns min object" do
      s1 = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      s1.min.should eq 1
      s1.delete 1
      s1.min.should eq 3

      n = 10**5
      s2 = AVLTree::SortedSet(Int32).new
      n.times { |i| s2 << i << i + n << i + 2*n }
      (3*n).times do |i|
        s2.min.should eq i
        s2.delete i
      end
    end
  end

  describe "#max" do
    it "returns max object" do
      s1 = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      s1.max.should eq 9
      s1.delete 9
      s1.max.should eq 5

      n = 10**5
      s2 = AVLTree::SortedSet(Int32).new
      n.times { |i| s2 << i << i + n << i + 2*n }
      (3*n).times do |i|
        s2.max.should eq 3*n - i - 1
        s2.delete 3*n - i - 1
      end
    end
  end

  describe "#first" do
    it "returns first object" do
      s1 = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      s1.first.should eq 1
      s1.delete 1
      s1.first.should eq 3

      n = 10**5
      s2 = AVLTree::SortedSet(Int32).new
      n.times { |i| s2 << i << i + n << i + 2*n }
      (3*n).times do |i|
        s2.first.should eq i
        s2.delete i
      end
    end
  end

  describe "#last" do
    it "returns last object" do
      s1 = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      s1.last.should eq 9
      s1.delete 9
      s1.last.should eq 5

      n = 10**5
      s2 = AVLTree::SortedSet(Int32).new
      n.times { |i| s2 << i << i + n << i + 2*n }
      (3*n).times do |i|
        s2.last.should eq 3*n - i - 1
        s2.delete 3*n - i - 1
      end
    end
  end

  describe "#min?" do
    it "returns min? object" do
      set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      set.min?.should eq 1
      set.delete 1
      set.min?.should eq 3
      set.clear
      set.min?.should eq nil
    end
  end

  describe "#max?" do
    it "returns max? object" do
      set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      set.max?.should eq 9
      set.delete 9
      set.max?.should eq 5
      set.clear
      set.max?.should eq nil
    end
  end

  describe "#first?" do
    it "returns first? object" do
      set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      set.first?.should eq 1
      set.delete 1
      set.first?.should eq 3
      set.clear
      set.first?.should eq nil
    end
  end

  describe "#last?" do
    it "returns last? object" do
      set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      set.last?.should eq 9
      set.delete 9
      set.last?.should eq 5
      set.clear
      set.last?.should eq nil
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
