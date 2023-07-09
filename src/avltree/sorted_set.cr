require "./sorted_map"

module AVLTree
  # `SortedSet` implements a collection of sorted values with no duplicates.
  struct SortedSet(T)
    include Enumerable(T)
    include Indexable(T)
    include Iterable(T)
  
    def initialize
      @map = SortedMap(T, Nil).new
    end
  
    # Optimized version of `new` used when *other* is also an `Indexable`
    def self.new(other : Indexable(T))
      SortedSet(T).new.concat(other)
    end
  
    def self.new(enumerable : Enumerable(T))
      SortedSet(T).new.concat(enumerable)
    end

    def fetch(index : Int, &)
      @map.fetch_at(index) { |i| yield i }[0]
    end

    def fetch(index : Int, default)
      @map.fetch_at(index) { default }[0]
    end

    def unsafe_fetch(index : Int)
      @map.unsafe_fetch(index)[0]
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
      first
    end

    def max
      last
    end

    def max?
      last
    end

    def count(object)
      includes?(object) ? 1 : 0
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
      false
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
  
    def each
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

    {% for method_name in ["less", "less_equal", "greater", "greater_equal"] %}
      def {{ method_name.id }}_object_with_index(object) : {T?, Int32?}
        item, index = @map.{{ method_name.id }}_item_with_index(object)
        if item
          {item.not_nil![0], index}
        else
          {nil, nil}
        end
      end

      def {{ method_name.id }}_object(object) : T?
        item = @map.{{ method_name.id }}_item(object)
        item ? item.not_nil![0] : nil
      end

      def {{ method_name.id }}_index(object) : Int32?
        @map.{{ method_name.id }}_index(object)
      end
    {% end %}

    def &(other : Set)
      smallest, largest = self, other
      if largest.size < smallest.size
        smallest, largest = largest, smallest
      end
  
      set = SortedSet(T).new
      smallest.each do |value|
        set << value if largest.includes?(value)
      end
      set
    end

    def |(other : Set(U)) forall U
      set = Set(T | U).new
      unordered_each { |value| set << value }
      other.unordered_each { |value| set << value }
      set
    end
  
    def +(other : Set(U)) forall U
      self | other
    end
  
    def -(other : Set)
      set = SortedSet(T).new
      unordered_each do |value|
        set << value unless other.includes?(value)
      end
      set
    end
  
    def -(other : Enumerable)
      clone.subtract other
    end
  
    def ^(other : Set(U)) forall U
      set = Set(T | U).new
      unordered_each do |value|
        set << value unless other.includes?(value)
      end
      other.unordered_each do |value|
        set << value unless includes?(value)
      end
      set
    end
  
    def ^(other : Enumerable(U)) forall U
      set = Set(T | U).new(self)
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
  
    def ==(other : Set)
      same?(other) || @map == other.@map
    end
  
    def ===(object : T)
      includes? object
    end
  
    def dup
      set = SortedSet(T).new
      set.map = map.dup
      set
    end
  
    def clone
      set = SortedSet(T).new
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
      pp.list("SortedSet{", self, "}")
    end
  
    def_hash @map
  
    def intersects?(other : Set)
      if size < other.size
        any? { |o| other.includes?(o) }
      else
        other.any? { |o| includes?(o) }
      end
    end
  
    def to_s(io : IO) : Nil
      io << "SortedSet{"
      join io, ", ", &.inspect(io)
      io << '}'
    end
  
    def subset?(other : Set)
      return false if other.size < size
      all? { |value| other.includes?(value) }
    end
  
    def proper_subset?(other : Set)
      return false if other.size <= size
      all? { |value| other.includes?(value) }
    end

    def superset?(other : Set)
      other.subset?(self)
    end
  
    def proper_superset?(other : Set)
      other.proper_subset?(self)
    end
  
    def object_id
      @map.object_id
    end
  
    def same?(other : Set)
      @map.same?(other.@map)
    end
  end
end

module Enumerable
  def to_sorted_set
    AVLTree::SortedSet.new(self)
  end
end
