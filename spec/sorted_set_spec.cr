require "spec"
require "../src/avltree/sorted_set"

describe AVLTree::SortedSet do
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

  describe "#unsafe_fetch" do
    it "unsafe_fetch" do
      set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      expect_raises(IndexError) { set.unsafe_fetch(-1) }
      set.unsafe_fetch(0).should eq 1
      set.unsafe_fetch(1).should eq 3
      set.unsafe_fetch(2).should eq 4
      set.unsafe_fetch(3).should eq 5
      set.unsafe_fetch(4).should eq 9
      expect_raises(IndexError) { set.unsafe_fetch(5) }
    end
  end

  describe "#at" do
    it "returns the element at the *index*-th." do
      r = Random.new(628)
      s = ::Set(Int32).new
      while s.size < 10**5
        s << r.rand(Int32::MIN..Int32::MAX)
      end

      set = AVLTree::SortedSet(Int32).new(s.to_a)

      s.to_a.sort.each_with_index do |ai, i|
        set.at(i).should eq ai
      end
    end
  end

  describe "#at(index, &)" do
    it "at?" do
      set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      set.at(-6) { "foo" }.should eq "foo"
      set.at(-5) { "foo" }.should eq 1
      set.at(-4) { "foo" }.should eq 3
      set.at(-3) { "foo" }.should eq 4
      set.at(-2) { "foo" }.should eq 5
      set.at(-1) { "foo" }.should eq 9
      set.at(0) { "foo" }.should eq 1
      set.at(1) { "foo" }.should eq 3
      set.at(2) { "foo" }.should eq 4
      set.at(3) { "foo" }.should eq 5
      set.at(4) { "foo" }.should eq 9
      set.at(5) { "foo" }.should eq "foo"
    end
  end

  describe "#at?" do
    it "at?" do
      set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      set.at?(-6).should eq nil
      set.at?(-5).should eq 1
      set.at?(-4).should eq 3
      set.at?(-3).should eq 4
      set.at?(-2).should eq 5
      set.at?(-1).should eq 9
      set.at?(0).should eq 1
      set.at?(1).should eq 3
      set.at?(2).should eq 4
      set.at?(3).should eq 5
      set.at?(4).should eq 9
      set.at?(5).should eq nil
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

  describe "#index" do
    it "index" do
      set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      ary = {1, 3, 4, 5, 9}
      set.index(0).should eq ary.index(0)
      set.index(1).should eq ary.index(1)
      set.index(2).should eq ary.index(2)
      set.index(3).should eq ary.index(3)
    end
  end

  describe "#index!" do
    it "index!" do
      set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      ary = {1, 3, 4, 5, 9}
      expect_raises(Enumerable::NotFoundError) { set.index!(0) }
      set.index!(1).should eq ary.index(1)
      expect_raises(Enumerable::NotFoundError) { set.index!(2) }
      set.index!(3).should eq ary.index(3)
    end
  end

  describe "#rindex" do
    it "rindex" do
      set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      ary = {1, 3, 4, 5, 9}
      set.rindex(0).should eq ary.rindex(0)
      set.rindex(1).should eq ary.rindex(1)
      set.rindex(2).should eq ary.rindex(2)
      set.rindex(3).should eq ary.rindex(3)
    end
  end

  describe "#rindex!" do
    it "rindex!" do
      set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      ary = {1, 3, 4, 5, 9}
      expect_raises(Enumerable::NotFoundError) { set.rindex!(0) }
      set.rindex!(1).should eq ary.rindex(1)
      expect_raises(Enumerable::NotFoundError) { set.rindex!(2) }
      set.rindex!(3).should eq ary.rindex(3)
    end
  end

  describe "#count" do
    it "count" do
      s1 = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      s1.count(1).should eq 1
      s1.count(2).should eq 0
      s1.count(2..3).should eq 1
      s1.count(2...3).should eq 0
      s1.count(2..9).should eq 4
      s1.count(2...9).should eq 3
      s1.count(2...).should eq 4
      s1.count(...).should eq 5
      s1.count(...9).should eq 4

      s2 = AVLTree::SortedSet(String){"C", "A", "D", "A", "E", "I"}
      s2.count("A").should eq 1
      s2.count("AA").should eq 0
      s2.count("B".."C").should eq 1
      s2.count("B"..."C").should eq 0
      s2.count("B".."I").should eq 4
      s2.count("B"..."I").should eq 3
      s2.count("B"...).should eq 4
      s2.count(...).should eq 5
      s2.count(..."I").should eq 4
    end
  end

  describe "#<<" do
    it "add" do
      s1 = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      s1.should eq AVLTree::SortedSet(Int32){1, 3, 4, 5, 9}
      s1 << 1 << 2 << 3 << 4 << 5 << 6 << 7 << 8 << 9 << 10
      s1.should eq AVLTree::SortedSet(Int32){1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    end
  end

  describe "#add" do
    it "add" do
      s1 = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      s1.should eq AVLTree::SortedSet(Int32){1, 3, 4, 5, 9}
      s1.add(1).add(2).add(3).add(4).add(5).add(6).add(7).add(8).add(9).add(10)
      s1.should eq AVLTree::SortedSet(Int32){1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    end
  end

  describe "#add?" do
    it "add?" do
      s1 = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      s1.should eq AVLTree::SortedSet(Int32){1, 3, 4, 5, 9}
      s1.add?(1).should eq false
      s1.add?(2).should eq true
      s1.add?(3).should eq false
      s1.add?(4).should eq false
      s1.add?(5).should eq false
      s1.add?(6).should eq true
      s1.add?(7).should eq true
      s1.add?(8).should eq true
      s1.add?(9).should eq false
      s1.add?(10).should eq true
      s1.should eq AVLTree::SortedSet(Int32){1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    end
  end

  describe "#concat" do
    it "concat" do
      set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      other = AVLTree::SortedSet(Int32){1, 4, 1, 4, 2}
      set.concat(other).should eq AVLTree::SortedSet{1, 2, 3, 4, 5, 9}
      set.should eq AVLTree::SortedSet{1, 2, 3, 4, 5, 9}
    end
  end

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

  describe "#delete" do
    it "Removes the object from the set and returns `true` if it was present, otherwise returns `false`." do
      set = AVLTree::SortedSet{1, 5}
      set.includes?(5).should eq true
      set.delete(5).should eq true
      set.includes?(5).should eq false
      set.delete(5).should eq false
    end
  end

  describe "#delete_at(index, &)" do
    it "Removes the *index*-th object and returns the deleted object, else yields `index` with given block." do
      set = AVLTree::SortedSet{1, 5}
      set.includes?(5).should eq true
      set.delete_at(1) { "foo" }.should eq 5
      set.includes?(5).should eq false
      set.delete_at(0) { "foo" }.should eq 1
      set.includes?(1).should eq false
      set.delete_at(0) { "foo" }.should eq "foo"
    end
  end

  describe "#delete_at" do
    it "Removes the *index*-th object from the set and returns the deleted object." do
      set = AVLTree::SortedSet{1, 5}
      set.includes?(5).should eq true
      set.delete_at(1).should eq 5
      set.includes?(5).should eq false
      set.delete_at(0).should eq 1
      set.includes?(1).should eq false
      expect_raises(IndexError) { set.delete_at(0) }
    end
  end

  describe "#delete_at?" do
    it "Removes the *index*-th object from the set and returns the deleted object if it was present, otherwise returns nil." do
      set = AVLTree::SortedSet{1, 5}
      set.includes?(5).should eq true
      set.delete_at?(1).should eq 5
      set.includes?(5).should eq false
      set.delete_at?(0).should eq 1
      set.includes?(1).should eq false
      set.delete_at?(0).should eq nil
    end
  end

  describe "#shift" do
    it "shift" do
      n = 10**5
      ary = [] of Int32
      2.times { n.times { |i| ary << i << i + n << i + 2*n } }
      set = AVLTree::SortedSet(Int32).new(ary)
      ary.uniq!.sort!.reverse!
      (3*n).times do
        set.shift.should eq ary.pop
      end
    end
  end

  describe "#shift(&)" do
    it "shift(&)" do
      set = AVLTree::SortedSet{1, 5}
      set.shift { "foo" }.should eq 1
      set.shift { "foo" }.should eq 5
      set.shift { "foo" }.should eq "foo"
    end
  end

  describe "#shift?" do
    it "shift?" do
      set = AVLTree::SortedSet{1, 5}
      set.shift?.should eq 1
      set.shift?.should eq 5
      set.shift?.should eq nil
    end
  end

  describe "#pop" do
    it "pop" do
      n = 10**5
      ary = [] of Int32
      2.times { n.times { |i| ary << i << i + n << i + 2*n } }
      set = AVLTree::SortedSet(Int32).new(ary)
      ary.uniq!.sort!
      (3*n).times do
        set.pop.should eq ary.pop
      end
    end
  end

  describe "#pop(&)" do
    it "pop(&)" do
      set = AVLTree::SortedSet{1, 5}
      set.pop { "foo" }.should eq 5
      set.pop { "foo" }.should eq 1
      set.pop { "foo" }.should eq "foo"
    end
  end

  describe "#pop?" do
    it "pop?" do
      set = AVLTree::SortedSet{1, 5}
      set.pop?.should eq 5
      set.pop?.should eq 1
      set.pop?.should eq nil
    end
  end

  describe "#size" do
    it "size" do
      set = AVLTree::SortedSet(Int32).new
      set.size.should eq 0
      set << 1
      set.size.should eq 1
      set << 1 << 2 << 3
      set.size.should eq 3
      set.clear
      set.size.should eq 0
    end
  end

  describe "#clear" do
    it "clear" do
      set = AVLTree::SortedSet(Int32).new
      set.should eq AVLTree::SortedSet(Int32).new
      set << 1
      set.should eq AVLTree::SortedSet(Int32){1}
      set << 1 << 2 << 3
      set.should eq AVLTree::SortedSet(Int32){1, 2, 3}
      set.clear
      set.should eq AVLTree::SortedSet(Int32).new
      set << 4 << 5 << 6
      set.should eq AVLTree::SortedSet(Int32){4, 5, 6}
    end
  end

  describe "#empty" do
    it "empty" do
      set = AVLTree::SortedSet(Int32).new
      set.empty?.should eq true
      set << 10
      set.empty?.should eq false
      set.clear
      set.empty?.should eq true
      set << 20
      set.empty?.should eq false
    end
  end

  describe "#each" do
    it "each" do
      set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      ary = {1, 3, 4, 5, 9}
      i = 0
      set.each do |elem|
        elem.should eq ary[i]
        i += 1
      end
    end
  end

  describe "#each(&)" do
    it "each(&)" do
      set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      set.each.join(", ").should eq "1, 3, 4, 5, 9"
      iter = set.each
      iter.next.should eq 1
      iter.next.should eq 3
      iter.next.should eq 4
      iter.next.should eq 5
      iter.next.should eq 9
    end
  end

  describe "#unordered_each(&)" do
    it "unordered_each(&)" do
      set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      sum = 0
      set.unordered_each do |elem|
        sum += elem
      end
      sum.should eq set.sum
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

  describe "#proper_subset_of?" do
    it "proper_subset_of?" do
      AVLTree::SortedSet.new([1, 5]).proper_subset_of?(AVLTree::SortedSet.new([1, 3, 5])).should eq true
      AVLTree::SortedSet.new([1, 3, 5]).proper_subset_of?(AVLTree::SortedSet.new([1, 3, 5])).should eq false
      AVLTree::SortedSet.new([1, 3, 5]).proper_subset_of?(AVLTree::SortedSet.new([1, 5])).should eq false
    end
  end

  describe "#proper_superset_of?" do
    it "proper_superset_of?" do
      AVLTree::SortedSet.new([1, 5]).proper_superset_of?(AVLTree::SortedSet.new([1, 3, 5])).should eq false
      AVLTree::SortedSet.new([1, 3, 5]).proper_superset_of?(AVLTree::SortedSet.new([1, 3, 5])).should eq false
      AVLTree::SortedSet.new([1, 3, 5]).proper_superset_of?(AVLTree::SortedSet.new([1, 5])).should eq true
    end
  end

  describe "#subset_of?" do
    it "subset_of?" do
      AVLTree::SortedSet.new([1, 5]).subset_of?(AVLTree::SortedSet.new([1, 3, 5])).should eq true
      AVLTree::SortedSet.new([1, 3, 5]).subset_of?(AVLTree::SortedSet.new([1, 3, 5])).should eq true
      AVLTree::SortedSet.new([1, 3, 5]).subset_of?(AVLTree::SortedSet.new([1, 5])).should eq false
    end
  end

  describe "#superset_of?" do
    it "superset_of?" do
      AVLTree::SortedSet.new([1, 5]).superset_of?(AVLTree::SortedSet.new([1, 3, 5])).should eq false
      AVLTree::SortedSet.new([1, 3, 5]).superset_of?(AVLTree::SortedSet.new([1, 3, 5])).should eq true
      AVLTree::SortedSet.new([1, 3, 5]).superset_of?(AVLTree::SortedSet.new([1, 5])).should eq true
    end
  end

  describe "#delete_at" do
    it "delete at" do
      set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
      set.to_a.should eq [1, 3, 4, 5, 9]
      set.delete_at(2)
      set.to_a.should eq [1, 3, 5, 9]
      set.delete_at(2)
      set.to_a.should eq [1, 3, 9]
      set.delete_at(1)
      set.to_a.should eq [1, 9]
      set.delete_at(1)
      set.to_a.should eq [1]
      set.delete_at(0)
      set.to_a.should eq [] of Int32
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
