import Foundation

struct PrimeDataPacket {
  let packetType: UInt8
  let gameID: UInt32
  let makerCode: UInt16
  let speed: (Float32, Float32, Float32)
  let pos: (Float32, Float32, Float32)
  let mlvl: UInt32
  let worldState: UInt32
  let room: UInt32
  let health: Float32
  let inventory: [UInt32]
  let timer: Float64

  static let size = 1 //packetType
                    + 4 //gameID
                    + 2 //makerCode
                    + 12 //speed
                    + 12 //pos
                    + 4 //mlvl
                    + 4 //state
                    + 4 //room
                    + 4 //health
                    + 328 //inventory (328 = 0x29 * 2 * 4)
                    + 8 //timer
                    + 0

  init(data: Data) {
    var parser = BinaryParser(data: data)
    packetType = parser.uint8()
    gameID = parser.uint32()
    makerCode = parser.uint16()
    speed = (parser.float32(), parser.float32(), parser.float32())
    pos = (parser.float32(), parser.float32(), parser.float32())
    mlvl = parser.uint32()
    worldState = parser.uint32()
    room = parser.uint32()
    health = parser.float32()
    inventory = Array(repeating: 0, count: 0x29 * 2).map({ _ in parser.uint32() })
    timer = parser.float64()
  }
}
