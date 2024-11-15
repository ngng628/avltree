require "./sorted_multimap"

module AVLTree
  # `SortedMultiset` implements a collection of sorted values with possible duplicates.
  #
  # ### Sample
  #
  # ```
  # require "avltree"
  #
  # mset = AVLTree::SortedMultiset(Int32).new
  # mset << 3 << 1 << 4 << 1 << 5 << 9
  #
  # mset # => SortedMultiset{1, 1, 3, 4, 5, 9}
  #
  # mset[0] # => 1
  # mset[1] # => 1
  # mset[2] # => 3  (SortedMultiset#[k] returns the kth object)
  #
  # mset.lower_bound(-1) # => 0
  # mset.lower_bound(2)  # => 2
  # mset.lower_bound(3)  # => 2
  # mset.lower_bound(9)  # => 5
  # mset.lower_bound(10) # => 6
  #
  # mset.delete(1)
  # mset # => SortedMultiset{1, 3, 4, 5, 9}
  # ```
  class SortedMultiset(T)
    include Enumerable(T)
    include Indexable(T)
    include Iterable(T)

    def initialize
      @map = SortedMultimap(T, Nil).new
    end

    def self.new(other : Indexable(T))
      SortedMultiset(T).new.concat(other)
    end

    def self.new(enumerable : Enumerable(T))
      SortedMultiset(T).new.concat(enumerable)
    end

    def fetch(index : Int, &)
      ret = @map.fetch_at(index) { nil }
      ret.nil? ? yield index : ret[0]
    end

    def fetch(index : Int, default)
      ret = @map.fetch_at(index) { nil }
      ret.nil? ? default : ret[0]
    end

    def unsafe_fetch(index : Int)
      @map.unsafe_fetch(index)[0]
    end

    # Returns the element at the *index*-th.
    def at(index : Int)
      fetch(index) { raise IndexError.new }
    end

    # Returns the element at the *index*-th.
    def at(index : Int, &)
      fetch(index) { |i| yield i }
    end

    # Like `at`, but returns `nil`
    # if trying to access an element outside the multiset's range.
    def at?(index : Int)
      fetch(index) { nil }
    end

    def first
      @map.first_key
    end

    def first?
      @map.first_key?
    end

    def last
      @map.last_key
    end

    def last?
      @map.last_key?
    end

    def min
      first
    end

    def min?
      first?
    end

    def max
      last
    end

    def max?
      last?
    end

    def index(object)
      @map.index(object)
    end

    def index!(object)
      @map.index!(object)
    end

    def rindex(object)
      @map.rindex(object)
    end

    def rindex!(object)
      @map.rindex!(object)
    end

    def count(object)
      upper_bound(object) - lower_bound(object)
    end

    # Returns the number of elements in the set that exist within the range
    #
    # ```
    # set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
    # set.count(0..1).should eq 2
    # set.count(0...1).should eq 0
    # set.count(0..2).should eq 2
    # set.count(0...2).should eq 2
    # set.count(2..3).should eq 1
    # set.count(2...3).should eq 0
    # set.count(2..9).should eq 4
    # set.count(2...9).should eq 3
    # set.count(2...).should eq 4
    # set.count(...).should eq 6
    # set.count(...9).should eq 5
    # ```
    def count(range : Range(T?, T?))
      b, e = range.begin, range.end
      left = b ? lower_bound(b) : 0
      right = if e.nil?
                size
              else
                if range.exclusive?
                  lower_bound(e)
                else
                  upper_bound(e)
                end
              end

      right - left
    end

    def <<(object : T)
      add object
    end

    def add(object : T)
      @map[object] = nil
      self
    end

    def add?(object : T)
      @map.put(object, nil) { return true }
      true
    end

    def concat(elems)
      elems.each { |elem| self << elem }
      self
    end

    def includes?(object)
      @map.has_key?(object)
    end

    def delete(object)
      @map.delete(object)
      self
    end

    def delete_at(object)
      @map.delete_at(object)
      self
    end

    def delete_at?(object)
      @map.delete_at?(object)
      self
    end

    def shift : T
      shift { raise IndexError.new }
    end

    def shift(&)
      object = first?
      if object
        delete(object)
        object
      else
        yield
      end
    end

    def shift? : T?
      shift { nil }
    end

    def pop : T
      pop { raise IndexError.new }
    end

    def pop(&)
      object = last?
      if object
        delete(object)
        object
      else
        yield
      end
    end

    def pop? : T?
      pop { nil }
    end

    def size
      @map.size
    end

    def clear
      @map.clear
      self
    end

    def empty?
      @map.empty?
    end

    def each(&)
      @map.each_key do |key|
        yield key
      end
    end

    def each
      @map.each_key
    end

    def unordered_each(&)
      @map.unordered_each do |key, _|
        yield key
      end
    end

    def lower_bound(object) : Int32
      @map.lower_bound(object)
    end

    def upper_bound(object) : Int32
      @map.upper_bound(object)
    end

    {% for method_name in ["largest_lt", "largest_leq", "smallest_gt", "smallest_geq"] %}
      def {{ method_name.id }}_with_index(object) : {T?, Int32?}
        item, index = @map.{{ method_name.id }}_with_index(object)
        if item.nil?
          {nil, nil}
        else
          {item[0], index}
        end
      end

      def {{ method_name.id }}(object) : T?
        item = @map.{{ method_name.id }}(object)
        item.try &.[0]
      end

      def index_of_{{ method_name.id }}(object) : Int32?
        @map.index_of_{{ method_name.id }}(object)
      end
    {% end %}

    def &(other : SortedMultiset)
      smallest, largest = self, other
      if largest.size < smallest.size
        smallest, largest = largest, smallest
      end

      set = SortedMultiset(T).new
      smallest.each do |value|
        set << value if largest.includes?(value)
      end
      set
    end

    def |(other : SortedMultiset(U)) forall U
      set = SortedMultiset(T | U).new
      unordered_each { |value| set << value }
      other.unordered_each { |value| set << value }
      set
    end

    def +(other : SortedMultiset(U)) forall U
      self | other
    end

    def -(other : SortedMultiset)
      set = SortedMultiset(T).new
      unordered_each do |value|
        set << value unless other.includes?(value)
      end
      set
    end

    def -(other : Enumerable)
      clone.subtract other
    end

    def ^(other : SortedMultiset(U)) forall U
      set = SortedMultiset(T | U).new
      unordered_each do |value|
        set << value unless other.includes?(value)
      end
      other.unordered_each do |value|
        set << value unless includes?(value)
      end
      set
    end

    def ^(other : Enumerable(U)) forall U
      set = SortedMultiset(T | U).new(self)
      other.unordered_each do |value|
        if includes?(value)
          set.delete value
        else
          set << value
        end
      end
      set
    end

    def subtract(other : Enumerable)
      other.unordered_each do |value|
        delete value
      end
      self
    end

    def ==(other : SortedMultiset)
      same?(other) || @map == other.@map
    end

    def ===(other : T)
      includes? other
    end

    def dup
      set = SortedMultiset(T).new
      set.map = map.dup
      set
    end

    def clone
      set = SortedMultiset(T).new
      set.map = map.clone
      set
    end

    def to_a
      @map.keys
    end

    def inspect(io : IO) : Nil
      to_s(io)
    end

    def pretty_print(pp) : Nil
      pp.list("SortedMultiset{", self, "}")
    end

    def_hash @map

    def intersects?(other : SortedMultiset)
      if size < other.size
        any? { |object| other.includes?(object) }
      else
        other.any? { |object| includes?(object) }
      end
    end

    def to_s(io : IO) : Nil
      io << "SortedMultiset{"
      join io, ", ", &.inspect(io)
      io << '}'
    end

    def subset_of?(other : SortedMultiset)
      return false if other.size < size
      all? { |value| other.includes?(value) }
    end

    def proper_subset_of?(other : SortedMultiset)
      return false if other.size <= size
      all? { |value| other.includes?(value) }
    end

    def superset_of?(other : SortedMultiset)
      other.subset_of?(self)
    end

    def proper_superset?(other : SortedMultiset)
      other.proper_subset_of?(self)
    end

    def object_id
      @map.object_id
    end

    def same?(other : SortedMultiset)
      @map.same?(other.@map)
    end
  end
end

module Enumerable
  def to_sorted_multiset
    AVLTree::SortedMultiset.new(self)
  end
end
