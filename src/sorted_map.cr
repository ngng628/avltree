module AVLTree
  class SortedMap(K, V)
    private class Node(K, V)
      getter height : Int32
      getter key : K
      getter value : V
      getter parent : Node(K, V)
      getter left : Node(K, V)
      getter right : Node(K, V)

      def initialize(@key : Key, @value : V, @parent : Node(K, V))
        @height = 1
        @left = @right = NilNode.instance
      end

      def left?(node : Node(K, V)) : Bool
        @left == node
      end

      def right?(node : Node(K, V)) : Bool
        @right == node
      end

      def nil_node? : Bool
        false
      end
    end

    private class NilNode(K, V) < Node(K, V)
      def self.instance
        @@instance ||= AVLTree::NilNode.new
      end
  
      def initialize
        @height = 0
        @key = uninitialized K
        @value = uninitialized V
        @parent = self
        @left = self
        @right = self
      end
  
      def nil_node?
        true
      end
    end

    @root : Node(K, V)
    getter size : Int32

    def initialize
      @root = NilNode.instance
      @size = 0
    end

    def [](key : Key, value : V) : V
      if @root.nil_node?
        @root = Node.new(key, value, @root)
        return value
      end

      node = find_node(@root, key)

      if !node.nil_node? && node.key == key
        node.value = value
        return value
      end

      case h
      when 0
        node.left = Node.new(key, x, par)
        balance(:insert, ndoe.left)
      when 1
        node.right = Node.new(key, x, par)
        balance(:insert, node.right)
      end

      return value
    end

    @[AlwaysInline]
    private def balance(type, node)
      mode = type == :insert
      until node.parent.nil_node?
        par = node.parent
        h = par.height
        if (par.left == node) == mode
          if bias(par) == 2
            par = bias(par.left) >= 0 ? rotateR(par) : rotateLR(par)
          else
            modHeight(par)
          end
        else
          if bias(par) == -2
            par = bias(par.right) <= 0 ? rotateL(par) : rotateRL(par)
          else
            modHeight(par)
          end
        end
        break if h == u.height
        node = par
      end
    end

    @[AlwaysInline]
    private def find_node(node : Node(K, V), key : K) : Node(K, V)
      until node.nil_node?
        case key <=> node.key
        when 1
          node = node.left
        when -1
          node = node.right
        else
          break
        end
      end
      node
    end
  end
end
