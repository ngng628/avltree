module AVLTree
  class SortedMap(K, V)
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
      def left!
        @left.not_nil!
      end

      @[AlwaysInline]
      def right!
        @right.not_nil!
      end

      @[AlwaysInline]
      def parent!
        @parent.not_nil!
      end

      @[AlwaysInline]
      def balance_factor
        left_height = @left ? left!.height : 0
        right_height = @right ? right!.height : 0
        right_height - left_height
      end

      @[AlwaysInline]
      def update_height
        left_height = @left ? left!.height : 0
        right_height = @right ? right!.height : 0
        @height = 1 + Math.max(left_height, right_height)
      end

      @[AlwaysInline]
      def assign(node : Node(K, V))
        @key = node.key
        @value = node.value
      end

      def rotate_left : Node(K, V)
        r = right!
        m = r.left
        par = @parent

        if r.parent = par
          if par.not_nil!.left == self
            par.not_nil!.left = r
          else
            par.not_nil!.right = r
          end
        end

        m.parent = self if @right = m
        r.left = self
        @parent = r

        sz = @size
        @size += (m ? m.size : 0) - r.size
        r.size = sz

        update_height
        r.update_height

        r
      end

      def rotate_right : Node(K, V)
        l = left!
        m = l.right
        par = @parent

        if l.parent = par
          if par.not_nil!.left == self
            par.not_nil!.left = l
          else
            par.not_nil!.right = l
          end
        end

        m.not_nil!.parent = self if @left = m
        l.right = self
        @parent = l

        sz = @size
        @size += (m ? m.size : 0) - l.size
        l.size = sz

        update_height
        l.update_height

        l
      end

      def rotate_double_right : Node(K, V)
        l = left!
        par = @parent
        m = l.right!
        ml = m.left
        mr = m.right

        if m.parent = par
          if par.not_nil!.left == self
            par.not_nil!.left = m
          else
            par.not_nil!.right = m
          end
        end

        ml.not_nil!.parent = l if l.right = ml
        mr.not_nil!.parent = self if @left = mr

        m.left = l
        l.parent = m
        m.right = self
        @parent = m

        sz = @size
        @size += (mr ? mr.size : 0) - l.size
        l.size += (ml ? ml.size : 0) - m.size
        m.size = sz

        update_height
        l.update_height
        m.update_height

        m
      end

      def rotate_double_left : Node(K, V)
        r = right!
        par = @parent
        m = r.left!
        ml = m.left
        mr = m.right

        if m.parent = par
          if par.not_nil!.left == self
            par.not_nil!.left = m
          else
            par.not_nil!.right = m
          end
        end

        ml.not_nil!.parent = self if @right = ml
        mr.not_nil!.parent = r if r.left = mr

        m.left = self
        @parent = m
        m.right = r
        r.parent = m

        sz = @size
        @size += (ml ? ml.size : 0) - r.size
        r.size += (mr ? mr.size : 0) - m.size
        m.size = sz

        update_height
        r.update_height
        m.update_height

        m
      end
    end

    @root : Node(K, V)?

    def initialize
      @root = nil
    end

    def size : Int32
      @root ? @root.not_nil!.size : 0
    end

    def [](key : K) : V
      fetch(key) { raise KeyError.new "Missing hash key: #{key.inspect}" }
    end

    def fetch(key : K, default : V) : V
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

    def upsert(key : K, value : V) : V
      if @root.nil?
        @root = Node(K, V).new(key, value)
        return value
      end

      node = find_node(@root, key).not_nil!
      if node.key == key
        node.value = value
        return value
      end

      new_node = Node(K, V).new(key, value, node)
      if key < node.key
        node.left = new_node
      else
        node.right = new_node
      end

      node = new_node

      while node.parent
        par = node.parent!
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
      end

      if node.parent
        node = node.parent!
        par = node.parent
        while par
          par.size += 1
          par.update_height
          node = par
          par = node.parent
        end
      end

      @root = node

      value
    end

    def []=(key : K, value : V) : V
      upsert(key, value)
    end

    def delete(key : K) : V?
      delete(key) { nil }
    end

    def delete(key : K, &)
      entry = delete_impl(key)
      entry ? entry : yield key
    end

    private def delete_impl(key : K) : V?
      return nil if @root.nil?

      node = find_node(@root, key).not_nil!
      return nil if node.key != key

      entry = node.value

      par = node.parent

      if node.left.nil? || node.right.nil?
        n_node = node.left || node.right
        if par
          if key < par.not_nil!.key
            par.left = n_node
          else
            par.right = n_node
          end
        end
        node.parent = par if node = n_node
      else
        child = find_node(node.right, key).not_nil!
        n_node = child.right
        child_par = child.parent

        if node.right == child
          n_node.not_nil!.parent = child_par if node.right = n_node
        else
          n_node.not_nil!.parent = child_par if child_par.not_nil!.left = n_node
        end

        node.assign(child)
        node = n_node
        par = child_par
      end

      while par
        par.size -= 1
        par.update_height
        if par.not_nil!.left == node
          if par.not_nil!.balance_factor == 2
            sib = par.not_nil!.right!
            node = sib.balance_factor < 0 ? par.not_nil!.rotate_double_left : par.not_nil!.rotate_left
          else
            break if par.balance_factor == 1
            node = par
          end
        else
          if par.balance_factor == -2
            sib = par.not_nil!.left!
            node = sib.balance_factor > 0 ? par.not_nil!.rotate_double_right : par.not_nil!.rotate_right
          else
            break if par.balance_factor == -1
            node = par
          end
        end
        par = node.not_nil!.parent
      end

      if par
        node = par
        par = par.not_nil!.parent
        while par
          par.size -= 1
          par.update_height
          node = par
          par = node.parent
        end
      end

      @root = node

      entry
    end

    def has_key?(key : K) : Bool
      return false if @root.nil?

      node = find_node(@root, key)
      if !node.nil? && node.key == key
        return true
      end

      false
    end

    def empty?
      @root.nil?
    end

    def dump(node = @root, depth = 0)
      if node.nil?
        puts "NULL"
        return
      end
      puts ("----" * depth) + " #{node.not_nil!.key} (#{node.not_nil!.size})"
      dump(node.not_nil!.left!, depth + 1) unless node.not_nil!.left.nil?
      dump(node.not_nil!.right!, depth + 1) unless node.not_nil!.right.nil?
    end

    @[AlwaysInline]
    private def find_node(node : Node(K, V)?, key : K) : Node(K, V)?
      return nil if node.nil?
      until node.not_nil!.key == key
        if key < node.not_nil!.key
          break if node.not_nil!.left.nil?
          node = node.not_nil!.left
        else
          break if node.not_nil!.right.nil?
          node = node.not_nil!.right
        end
      end
      node
    end
  end
end
