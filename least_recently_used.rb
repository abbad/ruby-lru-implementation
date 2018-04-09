class LeastRecentlyUsed
  attr_accessor :previous, :next
  def initialize(capacity=3)
    if capacity <= 0
      raise 'Capacity should be bigger than 0'
    end
    @capacity = capacity
    @cache = {}
    @head = nil
  end

  def get(key)
    node = @cache[key]
    unless node
      return nil
    end

    if @cache.length == 1
      node.previous_node = nil
      @tail = node
      @head = node
    else
      if node == @tail
        @tail = @tail.next_node
        @tail.previous_node = nil
      end

      old_head = @head
      old_head.next_node = node

      previous_node = node.previous_node
      next_node = node.next_node
      if previous_node
        next_node.previous_node = previous_node # b
        previous_node.next_node = next_node
      end

      node.next_node = nil
      node.previous_node = old_head
      @head = node
    end

    node.value
  end

  def put(key, value)
    node = Node.new(value, key)
    if @cache.key?(key)
      get(key)
    else
      @cache[key] = node
      if @cache.length == 1
        get(key)
      elsif @cache.length <= @capacity
        get(key)
      else
        @cache.delete(@tail.key)
        get(key)
        @tail = @tail.next_node
        @tail.previous_node = nil
      end
    end
  end
end


class Node
  attr_accessor :value, :next_node, :previous_node, :key

  def initialize(value, key)
    @value = value
    @previous_node = nil
    @next_node = nil
    @key = key
  end
end
