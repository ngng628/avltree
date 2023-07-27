require "spec"

require "../src/avltree/sorted_map"

describe AVLTree::SortedMap do
  describe "#clone" do
    it "clone" do
      map_a = AVLTree::SortedMap(String, AVLTree::SortedMap(String, String)).new(
        {"foobar" => AVLTree::SortedMap(String, String).new({"foo" => "bar"})}
      )
      map_b = map_a.clone
      map_b["foobar"]["foo"] = "baz"
      map_a.should_not eq map_b
    end
  end

  describe "#compact" do
    it "returns new SortedMap without nil values." do
      map = AVLTree::SortedMap(String, String?).zip(["hello", "foo"], ["world", nil])
      map2 = AVLTree::SortedMap(String, String).zip(["hello"], ["world"])
      map.compact.should eq map2
    end
  end

  describe "#[]" do
    it "Returns the value for the key given by *key*." do
      map = AVLTree::SortedMap(String, String).new({"foo" => "bar"})
      map["foo"].should eq "bar"
    end
  end

  describe "#[]?" do
    it "Returns the value for the key given by key. If not found, returns `nil`" do
      map = AVLTree::SortedMap(String, String).new({"foo" => "bar"})
      map["foo"]?.should eq "bar"
      map["bar"]?.should eq nil
    end
  end

  describe "#[]?" do
    it "Empties a SortedMap and returns it." do
      map = AVLTree::SortedMap(String, String).new({"foo" => "bar"})
      map.clear.should eq AVLTree::SortedMap(String, String).new
      map.empty?.should eq true
    end
  end

  describe "#delete" do
    it "Deletes the key-value pair and returns the value, otherwise returns `nil`." do
      map = AVLTree::SortedMap(String, String).new({"foo" => "bar"})
      map.delete("foo").should eq "bar"
      map.fetch("foo", nil).should eq nil
    end
  end

  describe "#dig" do
    it "Traverses the depth of a structure and returns the value, otherwise raises `KeyError`." do
      map = AVLTree::SortedMap(String, AVLTree::SortedMap(String, Array(Int32))).new(
        {"a" => AVLTree::SortedMap(String, Array(Int32)).new({"b" => [10, 20, 30]})}
      )
      map.dig("a", "b").should eq [10, 20, 30]
      expect_raises(KeyError) do
        map.dig "a", "x"
      end
    end
  end

  describe "#dig?" do
    it "Traverses the depth of a structure and returns the value, otherwise raises `KeyError`." do
      map = AVLTree::SortedMap(String, AVLTree::SortedMap(String, Array(Int32))).new(
        {"a" => AVLTree::SortedMap(String, Array(Int32)).new({"b" => [10, 20, 30]})}
      )
      map.dig?("a", "b").should eq [10, 20, 30]
      map.dig?("a", "z").should eq nil
    end
  end

  describe "#max" do
    it "Returns an key of maximum." do
      map = AVLTree::SortedMap(Int32, Int32).new
      (0..10).each do |i|
        map[-((10 - i)**2)] = i
      end
      map.max.should eq({0, 10})
    end
  end

  describe "#min" do
    it "Returns an key of minimum." do
      map = AVLTree::SortedMap(Int32, Int32).new
      (0..10).each do |i|
        map[-((10 - i)**2)] = i
      end
      map.min.should eq({-100, 0})
    end
  end

  describe "#index" do
    it "index" do
      map = AVLTree::SortedMap(String, Int32).new
      map["alice"] = 1
      map["bob"] = 2
      map["carol"] = 3

      map.index("alice").should eq 0
      map.index("bob").should eq 1
      map.index("carol").should eq 2
      map.index("zoe").should eq nil
    end
  end

  describe "#index!" do
    it "index!" do
      map = AVLTree::SortedMap(String, Int32).new
      map["alice"] = 1
      map["bob"] = 2
      map["carol"] = 3

      map.index!("alice").should eq 0
      map.index!("bob").should eq 1
      map.index!("carol").should eq 2
    end
  end

  describe "#unordered_each" do
    it "yield unordered each elements." do
      map = AVLTree::SortedMap(String, Int32).new
      map["alice"] = 1
      map["bob"] = 2
      map["carol"] = 3

      ans = [{"bob", 2}, {"alice", 1}, {"carol", 3}]

      i = 0
      map.unordered_each do |key, value|
        key.should eq ans[i][0]
        value.should eq ans[i][1]
        i += 1
      end
    end
  end
end
