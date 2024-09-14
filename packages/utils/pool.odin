package utils

PoolHeader :: struct {
  next: ^PoolHeader
}

Pool :: struct($Object: typeid) {
  capacity: u64,
  count: u64,
  slots: []Object,
  free_list_head: ^PoolHeader
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