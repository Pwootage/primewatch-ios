import Foundation

//Big Endian

struct BinaryParser {
  let data: NSData
  var ptr: Int = 0

  init(data: Data) {
    self.data = data as NSData
  }

  mutating func get(_ res: UnsafeMutableRawPointer, len: Int) {
    data.getBytes(res, range: NSRange(location: ptr, length: len))
    ptr += len
  }

  mutating func int8() -> Int8 {
    var res: Int8 = 0
    get(&res, len: 1)
    return res
  }

  mutating func int16() -> Int16 {
    var res: Int16 = 0
    get(&res, len: 2)
    return Int16(bigEndian: res)
  }

  mutating func int32() -> Int32 {
    var res: Int32 = 0
    get(&res, len: 4)
    return Int32(bigEndian: res)
  }

  mutating func int64() -> Int64 {
    var res: Int64 = 0
    get(&res, len: 8)
    return Int64(bigEndian: res)
  }

  mutating func uint8() -> UInt8 {
    return UInt8(bitPattern: int8())
  }

  mutating func uint16() -> UInt16 {
    return UInt16(bitPattern: int16())
  }

  mutating func uint32() -> UInt32 {
    return UInt32(bitPattern: int32())
  }

  mutating func uint64() -> UInt64 {
    return UInt64(bitPattern: int64())
  }

  mutating func float32() -> Float32 {
    return Float32(bitPattern: uint32())
  }

  mutating func float64() -> Float64 {
    return Float64(bitPattern: uint64())
  }
}
