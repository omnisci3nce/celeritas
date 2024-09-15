package utils

import "core:mem"

PoolFreeNode :: struct {
  next: ^PoolFreeNode
}

Pool :: struct($T: typeid) {
  capacity: u64,
  count: u64,
  slots: []T,
  free_list_head: ^PoolFreeNode
}

pool_create :: proc($T: typeid, capacity: u64) -> Pool(T) {
  pool := Pool(T) {
    capacity = capacity,
    count = 0,
    free_list_head = nil,
    slots = make_slice([]T, capacity)
  }

  return pool
}

pool_free_all :: proc(pool: ^Pool($T)) {
  // set all entries to be free
  for i in 0 ..< pool.capacity {
    byte_offset := i * size_of(T)
    free_node := PoolFreeNode { next = pool.free_list_head }
    if i == (pool.capacity - 1) {
      free_node.next = nil
    }
    // store the PoolFreeNode in the T's slot itself
    mem.copy(pool.slots[i], &free_node, size_of(PoolFreeNode))
    pool.free_list_head = &free_node
  }
}

pool_alloc :: proc(pool: ^Pool($T)) -> (raw_handle: u32, ptr: ^T) {
  // check if the pool is already full
  if pool.count == pool.capacity {
    assert(pool.free_list_head == nil, "Next free node pointer should be NULL when the pool is full")
    // TODO: log.warn
    return nil
  }

  // get the next free node
  item := pool.free_list_head

  // calculate handle (end - start / entry size = index)
  handle := u32((uintptr(item) - uintptr(pool.slots[0])) / sizeof(T))

  // update free list
  pool.free_list_head = item.next
  pool.count += 1

  mem.zero(item, 1)

  return handle, item
}

pool_get :: proc(pool: ^Pool($T), handle: u32) -> ^T {
  assert(handle < pool.capacity)
  return pool.slots[handle]
}