module AVLTree
  class SortedMultimap(K, V)
    include Enumerable({K, V})
    include Iterable({K, V})

    private class Node(K, V)
      property key : K
      property value : V
      property size : Int32
      property parent : Node(K, V)?
      property height : Int32
      property left : Node(K, V)?
      property right : Node(K, V)?

      def initialize(@key : K, @value : V, @parent : Node(K, V)? = nil)
        @left = @right = nil
        @size = 1
        @height = 1
      end

      @[AlwaysInline]
      def balance_factor
        left_height = @left.try &.height || 0
        right_height = @right.try &.height || 0
        right_height - left_height
      end

      @[AlwaysInline]
      def update_height
        left_height = @left.try &.height || 0
        right_height = @right.try &.height || 0
        @height = 1 + Math.max(left_height, right_height)
      end

      @[AlwaysInline]
      def assign(node : Node(K, V))
        @key = node.key
        @value = node.value
      end

      def next : Node(K, V)?
        node = self
        if node.try &.right
          node = node.try &.right
          while node.try &.left
            node = node.try &.left
          end
          node
        else
          while node
            par = node.try &.parent
            if par && par.try &.left == node
              return par
            end
            node = par
          end
          node
        end
        node
      end

      def prev : Node(K, V)?
        node = self
        if node.try &.left
          node = node.try &.left
          while node.try &.right
            node = node.try &.right
          end
          node
        else
          while node
            par = node.try &.parent
            if par && par.try &.right == node
              return par
            end
            node = par
          end
          node
        end
        node
      end

      def rotate_left : Node(K, V)
        r = right
        raise NilAssertionError.new if r.nil?
        m = r.left
        par = @parent

        if r.parent = par
          if par.try &.left == self
            par.try &.left = r
          else
            par.try &.right = r
          end
        end

        m.parent = self if @right = m
        r.left = self
        @parent = r

        sz = @size
        @size += (m.try &.size || 0) - r.size
        r.size = sz

        update_height
        r.update_height

        r
      end

      def rotate_right : Node(K, V)
        l = left
        raise NilAssertionError.new if l.nil?
        m = l.right
        par = @parent

        if l.parent = par
          if par.try &.left == self
            par.try &.left = l
          else
            par.try &.right = l
          end
        end

        m.try &.parent = self if @left = m
        l.right = self
        @parent = l

        sz = @size
        @size += (m.try &.size || 0) - l.size
        l.size = sz

        update_height
        l.update_height

        l
      end

      def rotate_double_right : Node(K, V)
        l = left
        raise NilAssertionError.new if l.nil?
        par = @parent
        m = l.right
        raise NilAssertionError.new if m.nil?
        ml = m.left
        mr = m.right

        if m.parent = par
          if par.try &.left == self
            par.try &.left = m
          else
            par.try &.right = m
          end
        end

        ml.try &.parent = l if l.right = ml
        mr.try &.parent = self if @left = mr

        m.left = l
        l.parent = m
        m.right = self
        @parent = m

        sz = @size
        @size += (mr.try &.size || 0) - l.size
        l.size += (ml.try &.size || 0) - m.size
        m.size = sz

        update_height
        l.update_height
        m.update_height

        m
      end

      def rotate_double_left : Node(K, V)
        r = right
        raise NilAssertionError.new if r.nil?
        par = @parent
        m = r.left
        raise NilAssertionError.new if m.nil?
        ml = m.left
        mr = m.right

        if m.parent = par
          if par.try &.left == self
            par.try &.left = m
          else
            par.try &.right = m
          end
        end

        ml.try &.parent = self if @right = ml
        mr.try &.parent = r if r.left = mr

        m.left = self
        @parent = m
        m.right = r
        r.parent = m

        sz = @size
        @size += (ml.try &.size || 0) - r.size
        r.size += (mr.try &.size || 0) - m.size
        m.size = sz

        update_height
        r.update_height
        m.update_height

        m
      end
    end

    @root : Node(K, V)?
    @block : (self, K -> V)?

    def self.new(defalut_value : V)
      new { default_value }
    end

    def initialize(@block : (self, K -> V)? = nil)
      @root = nil
    end

    def self.new(&block : self, K -> V)
      new block
    end

    def initialize
      @root = nil
      @block = nil
    end

    def self.new(hash : Hash(K, V))
      map = self.new
      hash.each do |key, value|
        map[key] = value
      end
      map
    end

    def self.zip(ary1 : Array(K), ary2 : Array(V))
      map = self.new
      ary1.zip(ary2) do |key, value|
        map[key] = value
      end
      map
    end

    def ==(other : SortedMultimap) : Bool
      return false unless size == other.size
      other.unordered_each do |key, value|
        node = find_node(@root, key)
        return false if node.nil?
        return false if node.key != key
        return false if node.value != value
      end
      true
    end

    def clone
      map = SortedMultimap(K, V).new
      unordered_each do |key, value|
        map[key] = value.clone
      end
      map
    end

    def dup
      map = SortedMultimap(K, V).new
      map.root = @root.dup
      map.block = @block.dup
    end

    def put(key : K, value : V, &)
      updated_item = upsert(key, value)
      updated_item ? updated_item.value : yield key
    end

    def [](key : K) : V
      fetch(key) {
        if (block = @block) && key.is_a?(K)
          block.call(self, key.as(K))
        else
          raise KeyError.new "Missing hash key: #{key.inspect}"
        end
      }
    end

    def []?(key : K) : V?
      fetch(key, nil)
    end

    def []=(key : K, value : V) : V
      upsert(key, value)
      value
    end

    def update(key : K, & : V -> V) : V
      if has_key?(key)
        self[key] = yield self[key]
      elsif block = @block
        default_value = block.call(self, key)
        upsert(key, yield default_value)
        defalut_value
      else
        raise KeyError.new "Missing hash key: #{key.inspect}"
      end
    end

    def unsafe_fetch(index : Int)
      node = @root
      index += 1
      loop do
        left_size = (node.try &.left.try &.size || 0) + 1
        break if left_size == index

        if index < left_size
          node = node.try &.left
        else
          node = node.try &.right
          index -= left_size
        end
      end

      if node.nil?
        raise NilAssertionError.new
      else
        {node.key, node.value}
      end
    end

    def fetch_at(index : Int, &)
      index += size if index < 0
      return yield index unless 0 <= index && index < size
      unsafe_fetch(index)
    end

    def fetch_at(index : Int, default)
      fetch_at(index) { default }
    end

    def at(index : Int)
      fetch_at(index) { raise IndexError.new }
    end

    def at(index : Int, &)
      fetch_at(index) { |i| yield i }
    end

    def at?(index : Int)
      fetch_at(index) { nil }
    end

    # Returns the key at the *index*-th.
    def key_at(index : Int) : K
      ret = fetch_at(index, nil)
      if ret.nil?
        raise IndexError.new
      else
        ret[0]
      end
    end

    # Like `at`, but returns `nil`
    # if trying to access an key outside the set's range.
    def key_at?(index : Int) : K?
      item = at?(index)
      item.try &.[0]
    end

    # Returns the value at the *index*-th.
    def value_at(index : Int) : V
      ret = fetch_at(index, nil)
      if ret.nil?
        raise IndexError.new
      else
        ret[1]
      end
    end

    # Like `at`, but returns `nil`
    # if trying to access an value outside the set's range.
    def value_at?(index : Int) : V?
      item = at?(index)
      item.try &.[1]
    end

    def keys : Array(K)
      map &.[0]
    end

    def values : Array(V)
      map &.[1]
    end

    def values_by_key(*keys : K)
      keys.map { |key| self[key] }
    end

    def values_at(*indices : Int)
      indices.map { |index| self[index] }
    end

    def invert : SortedMultimap(V, K)
      map = SortedMultimap(V, K)
      each do |key, value|
        map[value] = key
      end
      map
    end

    def key_for(value) : K
      key_for(value) { raise KeyError.new "Missing hash key for value: #{value}" }
    end

    def key_for?(value) : K?
      key_for(value) { nil }
    end

    def key_for(value, &)
      each do |k, v|
        return k if v == value
      end
      yield value
    end

    def clear : self
      @root = nil
      self
    end

    def compact
      each_with_object(SortedMultimap(K, V).new) do |(key, value), memo|
        memo[key] = value unless value.nil?
      end
    end

    def compact! : self
      reject! { |_, value| value.nil? }
    end

    def size : Int32
      @root.try &.size || 0
    end

    def fetch(key : K, default)
      fetch(key) { default }
    end

    def fetch(key : K, &)
      node = find_node(@root, key)
      if node && node.key == key
        node.value
      else
        yield key
      end
    end

    def delete(key : K) : V?
      delete(key) { nil }
    end

    def delete(key : K, &)
      entry = delete_impl(key)
      entry ? entry : yield key
    end

    def delete_at(index : Int)
      key = key_at(index)
      delete(key)
    end

    def delete_at?(index : Int)
      key = key_at?(index)
      return nil if key.nil?
      delete(key)
    end

    def shift : Tuple(K, V)
      delete_at(0) { raise IndexError.new }
    end

    def shift(&)
      key = key_at?(0)
      if key
        delete(key)
      else
        yield
      end
    end

    def shift? : {K, V}?
      shift { nil }
    end

    def pop : Tuple(K, V)
      pop { raise IndexError.new }
    end

    def pop(&)
      key = key_at?(size - 1)
      if key
        delete(key)
      else
        yield
      end
    end

    def pop? : {K, V}?
      pop { nil }
    end

    def subset_of?(other : SortedMultimap(K, V)) : Bool
      return false if other.size < size
      all? { |key, value|
        other_value = other.fetch(key) { false }
        other_value == value
      }
    end

    def superset_of?(other : SortedMultimap(K, V)) : Bool
      other.subset_of?(self)
    end

    def proper_superset_of?(other : Hash) : Bool
      other.proper_subset_of?(self)
    end

    def dig(key : K, *subkeys)
      if (value = self[key]) && value.responds_to?(:dig)
        return value.dig(*subkeys)
      end
      raise KeyError.new "Hash value not diggable for key: #{key.inspect}"
    end

    def dig(key : K)
      self[key]
    end

    def dig?(key : K, *subkeys)
      if (value = self[key]?) && value.responds_to?(:dig?)
        return value.dig?(*subkeys)
      end
      nil
    end

    def dig?(key : K)
      self[key]?
    end

    def each(& : {K, V} ->) : Nil
      iter = ItemIterator(K, V).new(self)
      iter.each { |key_and_value| yield key_and_value }
    end

    def each
      ItemIterator(K, V).new(self)
    end

    def each_key(& : K ->) : Nil
      iter = KeyIterator(K, V).new(self)
      iter.each { |key| yield key }
    end

    def each_key
      KeyIterator(K, V).new(self)
    end

    def each_value(& : V ->) : Nil
      iter = ValueIterator(K, V).new(self)
      iter.each { |value| yield value }
    end

    def each_value
      ValueIterator(K, V).new(self)
    end

    def unordered_each(node = @root, & : {K, V} ->) : Nil
      return if node.nil?
      next_node = Deque.new([node])
      until next_node.empty?
        now = next_node.shift
        yield({now.key, now.value})
        l = now.left
        next_node << l if l
        r = now.right
        next_node << r if r
      end
    end

    def reverse_each(& : {K, V} ->) : Nil
      iter = ReverseItemIterator(K, V).new(self)
      iter.each { |key_and_value| yield key_and_value }
    end

    def reverse_each
      ReverseItemIterator(K, V).new(self)
    end

    def reverse_each_key(& : K ->) : Nil
      iter = ReverseKeyIterator(K, V).new(self)
      iter.reverse_each { |key| yield key }
    end

    def reverse_each_key
      ReverseKeyIterator(K, V).new(self)
    end

    def reverse_each_value(& : V ->) : Nil
      iter = ReverseValueIterator(K, V).new(self)
      iter.reverse_each { |value| yield value }
    end

    def reverse_each_value
      ReverseValueIterator(K, V).new(self)
    end

    def reject(& : K, V ->) : SortedMultimap(K, V)
      each_with_object(SortedMultimap(K, V).new) do |(key, value), memo|
        memo[key] = value unless yield key, value
      end
    end

    def reject!(& : K, V ->) : SortedMultimap(K, V)
      each do |key, value|
        delete(key) if yield key, value
      end
      self
    end

    def reject(*keys) : SortedMultimap(K, V)
      map = self.clone
      map.reject(*keys)
    end

    def reject!(keys : Enumerable) : SortedMultimap(K, V)
      keys.each { |key| delete(key) }
      self
    end

    def reject!(*keys) : SortedMultimap(K, V)
      reject!(*keys)
    end

    def select(keys : Enumerable) : SortedMultimap(K, V)
      keys.each_with_object(SortedMultimap(K, V).new) do |key, memo|
        value = self[key]?
        memo[key] = value if value
      end
    end

    def select(*keys) : SortedMultimap(K, V)
      self.select(keys)
    end

    def select!(keys : Indexable) : self
      each_key { |key| delete(key) unless k.in?(keys) }
      self
    end

    def select!(keys : Enumerable) : self
      key_set = keys.to_set
      each_key { |k| delete(k) unless k.in?(key_set) }
      self
    end

    def select!(*keys) : self
      select!(keys)
    end

    def first_key : K
      first_node.try &.key || raise "Can't get first key of empty SortedMap"
    end

    def first_key? : K?
      first_node.try &.key
    end

    def first_value : K
      first_node.try &.value || raise "Can't get first value of empty SortedMap"
    end

    def first_value? : K?
      first_node.try &.value
    end

    def last_key : K
      last_node.try &.key || raise "Can't get last key of empty SortedMap"
    end

    def last_key? : K?
      last_node.try &.key
    end

    def last_value : K
      last_node.try &.value || raise "Can't get last value of empty SortedMap"
    end

    def last_value? : K?
      last_node.try &.value
    end

    def lower_bound(key : K) : Int32
      lower_bound_impl(key)[1]
    end

    def upper_bound(key : K) : Int32
      upper_bound_impl(key)[1]
    end

    def less_item_with_index(key : K) : { {K, V}?, Int32? }
      return {nil, nil} if @root.nil?

      node, bound = lower_bound_impl(key)
      return {nil, nil} if bound == 0

      node = bound == size ? last_node : node.try &.prev
      return {nil, nil} if node.nil?

      { {node.key, node.value}, bound - 1}
    end

    def less_item(key : K) : {K, V}?
      less_item_with_index(key)[0]
    end

    def less_index(key : K) : Int32?
      less_item_with_index(key)[1]
    end

    def less_equal_item_with_index(key : K) : { {K, V}?, Int32? }
      return {nil, nil} if @root.nil?
      node, bound = lower_bound_impl(key)

      if !node.nil? && key == node.try &.key
        return { {node.key, node.value}, bound }
      end

      return {nil, nil} if bound == 0


      node = bound == size ? last_node : node.try &.prev
      return {nil, nil} if node.nil?

      { {node.key, node.value}, bound - 1 }
    end

    def less_equal_item(key : K) : {K, V}?
      less_equal_item_with_index(key)[0]
    end

    def less_equal_index(key : K) : Int32?
      less_equal_item_with_index(key)[1]
    end

    def greater_item_with_index(key : K) : { {K, V}?, Int32? }
      node, bound = upper_bound_impl(key)
      return {nil, nil} if bound == size
      return {nil, nil} if node.nil?

      { {node.key, node.value}, bound }
    end

    def greater_item(key : K) : {K, V}?
      greater_item_with_index(key)[0]
    end

    def greater_index(key : K) : Int32?
      greater_item_with_index(key)[1]
    end

    def greater_equal_item_with_index(key : K) : { {K, V}?, Int32? }
      node, bound = lower_bound_impl(key)
      return {nil, nil} if bound == size
      return {nil, nil} if node.nil?

      { {node.key, node.value}, bound }
    end

    def greater_equal_item(key : K) : {K, V}?
      greater_equal_item_with_index(key)[0]
    end

    def greater_equal_index(key : K) : Int32?
      greater_equal_item_with_index(key)[1]
    end

    def has_key?(key : K) : Bool
      return false if @root.nil?

      node = find_node(@root, key)
      if !node.nil? && node.key == key
        return true
      end

      false
    end

    def max
      node = last_node
      return nil if node.nil?
      {node.key, node.value}
    end

    def min
      node = first_node
      return nil if node.nil?
      {node.key, node.value}
    end

    def index(key : K) : Int32?
      item, index = less_equal_item_with_index(key)
      index && item.try &.[0] == key ? index : nil
    end

    def index!(key : K) : Int32
      item, index = less_equal_item_with_index(key)
      raise Enumerable::NotFoundError.new if index.nil?
      item.try &.[0] == key ? index : raise Enumerable::NotFoundError.new
    end

    def rindex(key : K) : Int32?
      node, bound = upper_bound_impl(key)
      if bound == size
        node = last_node
      end
      return nil if node.nil?
      pre = node.prev
      return nil if pre.nil?
      pre.key == key ? bound - 1 : nil
    end

    def rindex!(key : K) : Int32
      node, bound = upper_bound_impl(key)
      if bound == size
        node = last_node
      end
      return nil if node.nil?
      pre = node.prev
      return nil if pre.nil?
      pre.key == key ? bound - 1 : raise Enumerable::NotFoundError.new
    end

    def has_value?(value : V) : Bool
      each_value do |v|
        return true if v == value
      end
      false
    end

    def empty?
      @root.nil?
    end

    def inspect(io : IO) : Nil
      to_s(io)
    end

    def to_s(io : IO) : Nil
      io << "{"
      each_with_index do |(key, value), i|
        io << ", " if i != 0
        io << key << " => " << value
      end
      io << "}"
    end

    def to_a : Array({K, V})
      ary = Array({K, V}).new(self.size)
      each do |key, value|
        ary << {key, value}
      end
      ary
    end

    def to_hash
      hash = Hash(K, V).new(@block)
      each do |key, value|
        hash[key] = value
      end
      hash
    end

    # ameba:disable Metrics/CyclomaticComplexity
    private def upsert(key, value) : {K, V}
      node = find_node2(@root, key)

      if node.nil?
        @root = Node(K, V).new(key, value)
        return {key, value}
      end

      new_node = Node(K, V).new(key, value, node)
      if key <= node.key
        node.left = new_node
      else
        node.right = new_node
      end

      node = new_node
      par = node.try &.parent

      while par
        par.size += 1
        par.update_height
        if par.left == node
          if par.balance_factor == -2
            node = node.balance_factor > 0 ? par.rotate_double_right : par.rotate_right
          else
            break if par.balance_factor >= 0
            node = par
          end
        else
          if par.balance_factor == 2
            node = node.balance_factor < 0 ? par.rotate_double_left : par.rotate_left
          else
            break if par.balance_factor <= 0
            node = par
          end
        end
        par = node.parent
      end

      par = node.try &.parent
      if par
        node = par
        par = node.parent
        while par
          par.size += 1
          par.update_height
          node = par
          par = node.parent
        end
      end

      @root = node

      {key, value}
    end

    @[AlwaysInline]
    private def find_node(node : Node(K, V)?, key : K) : Node(K, V)?
      return nil if node.nil?
      until node.key == key
        if key <= node.key
          child = node.left
          break if child.nil?
          node = child
        else
          child = node.right
          break if child.nil?
          node = child
        end
      end
      node
    end

    @[AlwaysInline]
    private def find_node2(node : Node(K, V)?, key : K) : Node(K, V)?
      return nil if node.nil?
      loop do
        if key <= node.key
          child = node.left
          break if child.nil?
          node = child
        else
          child = node.right
          break if child.nil?
          node = child
        end
      end
      node
    end

    # ameba:disable Metrics/CyclomaticComplexity
    private def delete_impl(key : K) : V?
      node = find_node(@root, key)
      return nil if node.nil?
      return nil if node.key != key

      entry = node.value

      par = node.parent

      if node.left.nil? || node.right.nil?
        n_node = node.left || node.right
        if par
          if key <= par.key
            par.left = n_node
          else
            par.right = n_node
          end
        end
        node.parent = par if node = n_node
      else
        child = find_node2(node.right, key) || raise NilAssertionError.new
        n_node = child.right
        child_par = child.parent

        if node.right == child
          n_node.try &.parent = child_par if node.right = n_node
        else
          n_node.try &.parent = child_par if child_par.try &.left = n_node
        end

        node.assign(child)
        node = n_node
        par = child_par
      end

      until par.nil?
        par.size -= 1
        par.update_height
        if par.left == node
          if par.balance_factor == 2
            sib = par.try &.right
            raise NilAssertionError.new if sib.nil?
            node = sib.balance_factor < 0 ? par.rotate_double_left : par.rotate_left
          else
            break if par.balance_factor == 1
            node = par
          end
        else
          if par.balance_factor == -2
            sib = par.try &.left
            raise NilAssertionError.new if sib.nil?
            node = sib.balance_factor > 0 ? par.rotate_double_right : par.rotate_right
          else
            break if par.balance_factor == -1
            node = par
          end
        end
        par = node.parent
      end

      unless par.nil?
        node = par
        par = par.parent
        until par.nil?
          par.size -= 1
          par.update_height
          node = par
          par = node.parent
        end
      end

      @root = node

      entry
    end

    private def lower_bound_impl(key : K) : {Node(K, V)?, Int32}
      node = @root
      return {nil, 0} if @root.nil?
      bound = 0
      target = @root
      while node
        if key <= node.key
          target = node
          node = node.left
        else
          bound += (node.left.try &.size || 0) + 1
          node = node.right
        end
      end

      {target, bound}
    end

    private def upper_bound_impl(key : K) : {Node(K, V)?, Int32}
      node = @root
      return {nil, 0} if @root.nil?
      bound = 0
      target = @root
      while node
        if key < node.key
          target = node
          node = node.left
        else
          bound += (node.left.try &.size || 0) + 1
          node = node.right
        end
      end

      {target, bound}
    end

    protected def first_node : Node(K, V)?
      node = @root
      while node.try &.left
        node = node.try &.left
      end
      node
    end

    protected def last_node : Node(K, V)?
      node = @root
      while node.try &.right
        node = node.try &.right
      end
      node
    end

    private module BaseIterator(K, V)
      @node : Node(K, V)?

      def initialize(map : SortedMultimap(K, V))
        @node = map.first_node
      end

      def initialize(@node : Node(K, V)?)
      end

      def base_next(&)
        n = @node
        return stop if n.nil?
        item = yield n
        @node = n.next
        item
      end
    end

    private class ItemIterator(K, V)
      include BaseIterator(K, V)
      include Iterator({K, V})

      def next
        base_next { |item| {item.key, item.value} }
      end
    end

    private class KeyIterator(K, V)
      include BaseIterator(K, V)
      include Iterator(K)

      def next
        base_next &.key
      end
    end

    private class ValueIterator(K, V)
      include BaseIterator(K, V)
      include Iterator(V)

      def next
        base_next &.value
      end
    end

    private module BaseReverseIterator(K, V)
      @node : Node(K, V)?

      def initialize(map : SortedMultimap(K, V))
        @node = map.last_node
      end

      def initialize(@node : Node(K, V)?)
      end

      def base_next(&)
        n = @node
        return stop if n.nil?
        item = yield n
        @node = n.prev
        item
      end
    end

    private class ReverseItemIterator(K, V)
      include BaseReverseIterator(K, V)
      include Iterator({K, V})

      def next
        base_next { |item| {item.key, item.value} }
      end
    end

    private class ReverseKeyIterator(K, V)
      include BaseReverseIterator(K, V)
      include Iterator(K)

      def next
        base_next &.key
      end
    end

    private class ReverseValueIterator(K, V)
      include BaseReverseIterator(K, V)
      include Iterator(V)

      def next
        base_next &.value
      end
    end
  end
end
