require_relative "least_recently_used"
require "test/unit"

class LeastRecentlyUsedCacheTest < Test::Unit::TestCase

  def test_add_one_key
    lru = LeastRecentlyUsed.new()
    lru.put('a', 1)
    cache = lru.instance_variable_get(:@cache)

    assert_equal(cache.key?('a'), true)
    assert_equal(cache['a'].next_node, nil)
    assert_equal(cache['a'].previous_node, nil)

    tail = lru.instance_variable_get(:@tail)
    head = lru.instance_variable_get(:@head)

    assert_equal(cache['a'], head)
    assert_equal(cache['a'], tail)
  end

  def test_add_two_keys
    lru = LeastRecentlyUsed.new()
    lru.put('a', 1)
    lru.put('b', 2)
    cache = lru.instance_variable_get(:@cache)

    assert_equal(cache.key?('a'), true)
    assert_equal(cache.key?('b'), true)
    assert_equal(cache['a'].next_node, cache['b'])
    assert_equal(cache['a'].previous_node, nil)

    tail = lru.instance_variable_get(:@tail)
    head = lru.instance_variable_get(:@head)

    assert_equal(cache['b'], head)
    assert_equal(cache['a'], tail)
  end

  def test_add_three_keys
    lru = LeastRecentlyUsed.new()
    lru.put('a', 1)
    lru.put('b', 2)
    lru.put('c', 3)
    cache = lru.instance_variable_get(:@cache)

    assert_equal(cache.key?('a'), true)
    assert_equal(cache.key?('b'), true)
    assert_equal(cache.key?('c'), true)

    assert_equal(cache['a'].next_node, cache['b'])
    assert_equal(cache['a'].previous_node, nil)
    assert_equal(cache['b'].next_node, cache['c'])
    assert_equal(cache['b'].previous_node, cache['a'])
    assert_equal(cache['c'].next_node, nil)
    assert_equal(cache['c'].previous_node, cache['b'])

    tail = lru.instance_variable_get(:@tail)
    head = lru.instance_variable_get(:@head)

    assert_equal(cache['c'], head)
    assert_equal(cache['a'], tail)
  end

  def test_add_four_keys
    lru = LeastRecentlyUsed.new()
    lru.put('a', 1)
    lru.put('b', 2)
    lru.put('c', 3)
    lru.put('d', 4)
    cache = lru.instance_variable_get(:@cache)

    assert_equal(cache.key?('d'), true)
    assert_equal(cache.key?('c'), true)
    assert_equal(cache.key?('b'), true)
    assert_equal(cache.key?('a'), false)

    assert_equal(cache['d'].next_node, nil)
    assert_equal(cache['d'].previous_node, cache['c'])
    assert_equal(cache['c'].next_node, cache['d'])
    assert_equal(cache['c'].previous_node, cache['b'])
    assert_equal(cache['b'].next_node, cache['c'])
    assert_equal(cache['b'].previous_node, nil)

    tail = lru.instance_variable_get(:@tail)
    head = lru.instance_variable_get(:@head)
    #
    assert_equal(cache['d'], head)
    assert_equal(cache['b'], tail)
  end

  def test_add_five_keys
    lru = LeastRecentlyUsed.new()
    lru.put('a', 1)
    lru.put('b', 2)
    lru.put('c', 3)
    lru.put('d', 4)
    lru.put('e', 5)
    cache = lru.instance_variable_get(:@cache)

    assert_equal(cache.key?('e'), true)
    assert_equal(cache.key?('d'), true)
    assert_equal(cache.key?('c'), true)
    assert_equal(cache.key?('b'), false)
    assert_equal(cache.key?('a'), false)

    assert_equal(cache['e'].next_node, nil)
    assert_equal(cache['e'].previous_node, cache['d'])
    assert_equal(cache['d'].next_node, cache['e'])
    assert_equal(cache['d'].previous_node, cache['c'])
    assert_equal(cache['c'].next_node, cache['d'])
    assert_equal(cache['c'].previous_node, nil)

    tail = lru.instance_variable_get(:@tail)
    head = lru.instance_variable_get(:@head)

    assert_equal(cache['e'], head)
    assert_equal(cache['c'], tail)
  end

  def test_get_func_alters_order
    lru = LeastRecentlyUsed.new()
    lru.put('a', 1)
    lru.put('b', 2)
    lru.put('c', 3)

    cache = lru.instance_variable_get(:@cache)

    lru.get('a')

    tail = lru.instance_variable_get(:@tail)
    head = lru.instance_variable_get(:@head)

    assert_equal(cache['a'], head)
    assert_equal(cache['b'], tail)

    assert_equal(cache['c'].previous_node, cache['b'])
    assert_equal(cache['c'].next_node, cache['a'])
  end

  def test_get_func_alters_order_2
    lru = LeastRecentlyUsed.new(10)
    lru.put('a', 1)
    lru.put('b', 2)
    lru.put('c', 3)
    lru.put('d', 4)
    lru.put('e', 5)
    lru.put('f', 6)
    lru.put('g', 7)
    lru.put('h', 8)

    lru.get('c')
    cache = lru.instance_variable_get(:@cache)

    assert_equal(cache['c'].next_node, nil)
    assert_equal(cache['c'].previous_node, cache['h'])
    assert_equal(cache['h'].next_node, cache['c'])
    assert_equal(cache['h'].previous_node, cache['g'])
    assert_equal(cache['g'].next_node, cache['h'])
    assert_equal(cache['g'].previous_node, cache['f'])
    assert_equal(cache['f'].next_node, cache['g'])
    assert_equal(cache['f'].previous_node, cache['e'])
    assert_equal(cache['e'].next_node, cache['f'])
    assert_equal(cache['e'].previous_node, cache['d'])
    assert_equal(cache['d'].next_node, cache['e'])
    assert_equal(cache['d'].previous_node, cache['b'])
    assert_equal(cache['b'].next_node, cache['d'])
    assert_equal(cache['b'].previous_node, cache['a'])
    assert_equal(cache['a'].next_node, cache['b'])
    assert_equal(cache['a'].previous_node, nil)

    tail = lru.instance_variable_get(:@tail)
    head = lru.instance_variable_get(:@head)

    assert_equal(cache['c'], head)
    assert_equal(cache['a'], tail)

    lru.get('a')

    cache = lru.instance_variable_get(:@cache)

    assert_equal(cache['a'].next_node, nil)
    assert_equal(cache['a'].previous_node, cache['c'])
    assert_equal(cache['c'].next_node, cache['a'])
    assert_equal(cache['c'].previous_node, cache['h'])
    assert_equal(cache['h'].next_node, cache['c'])
    assert_equal(cache['h'].previous_node, cache['g'])
    assert_equal(cache['g'].next_node, cache['h'])
    assert_equal(cache['g'].previous_node, cache['f'])
    assert_equal(cache['f'].next_node, cache['g'])
    assert_equal(cache['f'].previous_node, cache['e'])
    assert_equal(cache['e'].next_node, cache['f'])
    assert_equal(cache['e'].previous_node, cache['d'])
    assert_equal(cache['d'].next_node, cache['e'])
    assert_equal(cache['d'].previous_node, cache['b'])
    assert_equal(cache['b'].next_node, cache['d'])
    assert_equal(cache['b'].previous_node, nil)

    tail = lru.instance_variable_get(:@tail)
    head = lru.instance_variable_get(:@head)

    assert_equal(cache['a'], head)
    assert_equal(cache['b'], tail)
  end

  def test_get_func_empty
    lru = LeastRecentlyUsed.new()

    assert_equal(lru.get('a'), nil)
  end

  def test_initilize_capacity_less_0
    assert_raise do
      lru = LeastRecentlyUsed.new(0)
    end

    assert_raise do
      lru = LeastRecentlyUsed.new(-11)
    end
  end
end
