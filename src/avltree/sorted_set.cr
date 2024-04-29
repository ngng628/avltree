require "./sorted_map"

module AVLTree
  # `SortedSet` implements a Set that guarantees that its elements are yielded in sorted order
  # (according to the return values of their #<=> methods) when iterating over them.
  #
  # `SortedSet` utilizes an internally implemented `SortedMap` using an AVL tree.
  #
  # While it often has slower computational speed compared to a Set implemented using a hash-based approach,
  # it offers potential optimizations for operations related to order.
  # For example, retrieving the maximum and minimum values of the set can be performed in logarithmic time.
  #
  # `SortedSet` does not allow duplicates and only stores unique values.
  #
  # ### Example
  #
  # ```
  # require "avltree"
  #
  # set = AVLTree::SortedSet.new [3, 1, 4]
  # set.to_a == [1, 3, 4] # => true
  # set.to_a == [3, 1, 4] # => false
  #
  # set << 1 << 5
  # set                 # => SortedSet{1, 3, 4, 5}
  # set.min             # => 1  (O(logN))
  # set.max             # => 5  (O(logN))
  # set.index(4)        # => 2  (O(logN))
  # set.upper_bound(2)  # => 1  (O(logN))
  # set.upper_bound(3)  # => 1  (O(logN))
  # set.upper_bound(10) # => 4  (O(logN))
  # ```
  class SortedSet(T)
    include Enumerable(T)
    include Indexable(T)
    include Iterable(T)

    def initialize
      @map = SortedMap(T, Nil).new
    end

    def self.new(other : Indexable(T))
      SortedSet(T).new.concat(other)
    end

    def self.new(enumerable : Enumerable(T))
      SortedSet(T).new.concat(enumerable)
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
    # if trying to access an element outside the set's range.
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
      includes?(object) ? 1 : 0
    end

    # Returns the number of elements in the set that exist within the range.
    #
    # ```
    # set = AVLTree::SortedSet(Int32){3, 1, 4, 1, 5, 9}
    # set.count(2..3)  # => 1
    # set.count(2...3) # => 0
    # set.count(2..9)  # => 4
    # set.count(2...9) # => 3
    # set.count(2...)  # => 4
    # set.count(...)   # => 5
    # set.count(...9)  # => 4
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
      false
    end

    def concat(elems)
      elems.each { |elem| self << elem }
      self
    end

    def includes?(object)
      @map.has_key?(object)
    end

    # Removes the object from the set and returns `true` if it was present, otherwise returns `false`.
    def delete(object)
      @map.delete(object) { return false }
      true
    end

    # Removes the *index*-th object and returns the deleted object, else yields `index` with given block.
    def delete_at(index : Int, &)
      entry = @map.delete_at?(index)
      return yield index if entry.nil?
      entry[0]
    end

    # Removes the *index*-th object from the set and returns the deleted object.
    def delete_at(index : Int) : T
      @map.delete_at(index)[0]
    end

    # Removes the *index*-th object from the set and returns the deleted object if it was present, otherwise returns nil.
    def delete_at?(index : Int) : T?
      @map.delete_at?(index).try &.[0]
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

    # Removes all elements in the set, and returns self.
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

    # Yields each element of the set, and returns self.
    #
    # It doesn't guarantee that its elements are yielded in sorted order when iterating over them.
    def unordered_each(&)
      @map.unordered_each do |key, _|
        yield key
      end
      self
    end

    # ```
    # set = AVLTree::SortedSet(String){"A", "B", "B", "C", "E"}
    # set                  # => SortedSet{"A", "B", "C", "E"}
    # set.lower_bound("@") # => 0
    # set.lower_bound("A") # => 0
    # set.lower_bound("B") # => 1
    # set.lower_bound("C") # => 2
    # set.lower_bound("D") # => 3
    # set.lower_bound("E") # => 3
    # set.lower_bound("F") # => 4
    # set.lower_bound("Z") # => 4
    # ```
    def lower_bound(object) : Int32
      @map.lower_bound(object)
    end

    # ```
    # set = AVLTree::SortedSet(String){"A", "B", "B", "C", "E"}
    # set                  # => SortedSet{"A", "B", "C", "E"}
    # set.upper_bound("@") # => 0
    # set.upper_bound("A") # => 1
    # set.upper_bound("B") # => 2
    # set.upper_bound("C") # => 3
    # set.upper_bound("D") # => 3
    # set.upper_bound("E") # => 4
    # set.upper_bound("F") # => 4
    # set.upper_bound("Z") # => 4
    # ```
    def upper_bound(object) : Int32
      @map.upper_bound(object)
    end

    {% for method_name in ["less", "less_equal", "greater", "greater_equal"] %}
      # See `SortedMap#{{ method_name.id }}_item_with_index`
      def {{ method_name.id }}_object_with_index(object) : {T?, Int32?}
        item, index = @map.{{ method_name.id }}_item_with_index(object)
        if item.nil?
          {nil, nil}
        else
          {item[0], index}
        end
      end

      # See `SortedMap#{{ method_name.id }}_item`
      def {{ method_name.id }}_object(object) : T?
        item = @map.{{ method_name.id }}_item(object)
        item.try &.[0]
      end

      # See `SortedMap#{{ method_name.id }}_index`
      def {{ method_name.id }}_index(object) : Int32?
        @map.{{ method_name.id }}_index(object)
      end
    {% end %}

    def &(other : SortedSet) : SortedSet(T)
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

    def |(other : SortedSet(U)) : SortedSet(U | T) forall U
      set = SortedSet(T | U).new
      unordered_each { |value| set << value }
      other.unordered_each { |value| set << value }
      set
    end

    def +(other : SortedSet(U)) : SortedSet(T | U) forall U
      self | other
    end

    def -(other : SortedSet)
      set = SortedSet(T).new
      unordered_each do |value|
        set << value unless other.includes?(value)
      end
      set
    end

    def -(other : Enumerable)
      clone.subtract other
    end

    def ^(other : SortedSet(U)) forall U
      set = SortedSet(T | U).new
      unordered_each do |value|
        set << value unless other.includes?(value)
      end
      other.unordered_each do |value|
        set << value unless includes?(value)
      end
      set
    end

    def ^(other : Enumerable(U)) forall U
      set = SortedSet(T | U).new(self)
      other.each do |value|
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

    def ==(other : SortedSet)
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

    def subset_of?(other : SortedSet)
      return false if other.size < size
      all? { |value| other.includes?(value) }
    end

    def proper_subset_of?(other : SortedSet)
      return false if other.size <= size
      all? { |value| other.includes?(value) }
    end

    def superset_of?(other : SortedSet)
      other.subset_of?(self)
    end

    def proper_superset_of?(other : SortedSet)
      other.proper_subset_of?(self)
    end

    def object_id
      @map.object_id
    end

    def same?(other : SortedSet)
      @map.same?(other.@map)
    end
  end
end

module Enumerable
  def to_sorted_set
    AVLTree::SortedSet.new(self)
  end
end
