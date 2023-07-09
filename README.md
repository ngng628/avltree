# AVLTree

[![GitHub release](https://img.shields.io/github/release/ngng628/avltree.svg)](https://github.com/ngng628/avltree/releases) [![License: MIT](https://img.shields.io/badge/License-MIT-red.svg)](https://opensource.org/licenses/MIT)


An implement of `SortedSet`, `SortedMap` and `SortedMultiset` using [AVL tree](https://en.wikipedia.org/wiki/AVL_tree).

Each method is implemented to be as compliant as possible with the standard `Set` and `Hash` in the Crystal language.

## :arrow_down: Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     avltree:
       github: ngng628/avltree
   ```

2. Run `shards install`

## :pencil2: Usage

```crystal
require "avltree"
```

## :bulb: Sample

If you want more details, please refer to the API documentation.

```crystal
set = AVLTree::SortedSet(Int32).new
set << 3 << 1 << 4 << 1 << 5 << 9

set # => SortedSet{1, 3, 4, 5, 9}

set[0] # => 1
set[1] # => 3
set[2] # => 4  (SortedSet#[k] returns the kth object)

set.lower_bound(-1) # => 0
set.lower_bound(2) # => 1
set.lower_bound(3) # => 1
set.lower_bound(9) # => 4
set.lower_bound(10) # => 5

set.delete(1)
set # => SortedSet{3, 4, 5, 9}
```

```crystal
map = AVLTree::SortedMap(String, Int32).new

map["alice"] = 10
map["alice"] # => 10
map["carol"] = 20
map["carol"] # => 20
map["bob"] = -10
map["bob"] # => -10

map.at(0) # => {"alice", 10}
map.at(1) # => {"bob", -10}
map.at(2) # => {"carol", 20}  (at(k) returns the key-value pair to the kth key.)

map.lower_bound("a") # => 0
map.lower_bound("bob") # => 1
map.lower_bound("dave") # => 3

map.delete("alice")
map # {"bob" => -10, "carol" => 20}
map.delete_at(1)
map # {"bob" => -10}
```

```crystal
mset = AVLTree::SortedMultiset(Int32).new
mset << 3 << 1 << 4 << 1 << 5 << 9

mset # => SortedMultiset{1, 1, 3, 4, 5, 9}

mset[0] # => 1
mset[1] # => 1
mset[2] # => 3  (SortedMultiset#[k] returns the kth object)

mset.lower_bound(-1) # => 0
mset.lower_bound(2) # => 2
mset.lower_bound(3) # => 2
mset.lower_bound(9) # => 5
mset.lower_bound(10) # => 6

mset.delete(1)
mset # => SortedMultiset{1, 3, 4, 5, 9}
```


## :busts_in_silhouette: Contributing

1. Fork it (<https://github.com/ngng628/avltree/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am ':sparkles: Add some feature'`)
   - Please follow the `.gitmessage` format for the commit message.
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## :desktop_computer: Contributors

- [ngng628](https://github.com/ngng628) - creator and maintainer
