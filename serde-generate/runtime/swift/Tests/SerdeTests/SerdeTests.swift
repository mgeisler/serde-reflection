//  Copyright (c) Facebook, Inc. and its affiliates.

import Serde
import XCTest

class SerdeTests: XCTestCase {
    func testSerializer() throws {
        let serializer = BcsSerializer()
        try serializer.serialize_u8(value: 255) // 1
        try serializer.serialize_u32(value: 1) // 4
        try serializer.serialize_u32(value: 1) // 4
        try serializer.serialize_u32(value: 2) // 4
        XCTAssertEqual(serializer.get_buffer_offset(), 13, "the buffer size should be same")
        XCTAssertEqual(serializer.output.getBuffer(), [255, 1, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0], "the array should be same")
    }

    func testDeserializer() throws {
        let deserializer = BincodeDeserializer(input: [1, 0, 0, 0])
        let result = try deserializer.deserialize_u32()
        XCTAssertEqual(result, 1, "should match")
    }

    func testSerializeUint8() throws {
        let serializer = BincodeSerializer()
        try serializer.serialize_u8(value: 255)
        let deserializer = BincodeDeserializer(input: serializer.get_bytes())
        let result = try deserializer.deserialize_u8()
        XCTAssertEqual(result, 255, "should be same")
    }

    func testSerializeUint16() throws {
        let serializer = BincodeSerializer()
        try serializer.serialize_u16(value: 65535)
        let deserializer = BincodeDeserializer(input: serializer.get_bytes())
        let result = try deserializer.deserialize_u16()
        XCTAssertEqual(result, 65535, "should be same")
    }

    func testSerializeUint32() throws {
        let serializer = BincodeSerializer()
        try serializer.serialize_u32(value: 4_294_967_295)
        let deserializer = BincodeDeserializer(input: serializer.get_bytes())
        let result = try deserializer.deserialize_u32()
        XCTAssertEqual(result, 4_294_967_295, "should be same")
    }

    func testSerializeInt8() throws {
        let serializer = BincodeSerializer()
        try serializer.serialize_u8(value: 127)
        let deserializer = BincodeDeserializer(input: serializer.get_bytes())
        let result = try deserializer.deserialize_u8()
        XCTAssertEqual(result, 127, "should be same")
    }

    func testSerializeInt16() throws {
        let serializer = BincodeSerializer()
        try serializer.serialize_i16(value: 32767)
        let deserializer = BincodeDeserializer(input: serializer.get_bytes())
        let result = try deserializer.deserialize_i16()
        XCTAssertEqual(result, 32767, "should be same")
    }

    func testSerializeInt32() throws {
        let serializer = BincodeSerializer()
        try serializer.serialize_i32(value: 2_147_483_647)
        let deserializer = BincodeDeserializer(input: serializer.get_bytes())
        let result = try deserializer.deserialize_i32()
        XCTAssertEqual(result, 2_147_483_647, "should be same")
    }

    func testSerializeInt64() throws {
        let serializer = BincodeSerializer()
        try serializer.serialize_i64(value: 9_223_372_036_854_775_807)
        let deserializer = BincodeDeserializer(input: serializer.get_bytes())
        let result = try deserializer.deserialize_i64()
        XCTAssertEqual(result, 9_223_372_036_854_775_807, "should be same")
    }

    func testSerializeU128() throws {
        let serializer = BcsSerializer()
        XCTAssertNoThrow(try serializer.serialize_u128(value: UInt128(high: UInt64.max, low: UInt64.max)))
        XCTAssertEqual(serializer.output.getBuffer(), [255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255], "the array should be same")

        let serializer2 = BcsSerializer()
        XCTAssertNoThrow(try serializer2.serialize_u128(value: UInt128(high: 0, low: 1)))
        XCTAssertEqual(serializer2.output.getBuffer(), [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], "the array should be same")

        let serializer3 = BcsSerializer()
        XCTAssertNoThrow(try serializer3.serialize_u128(value: UInt128(high: 0, low: 0)))
        XCTAssertEqual(serializer3.output.getBuffer(), [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], "the array should be same")
    }

    func testSerializeI128() throws {
        let serializer = BcsSerializer()
        XCTAssertNoThrow(try serializer.serialize_i128(value: Int128(high: -1, low: UInt64.max)))
        XCTAssertEqual(serializer.output.getBuffer(), [255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255], "the array should be same")

        let serializer2 = BcsSerializer()
        XCTAssertNoThrow(try serializer2.serialize_i128(value: Int128(high: 0, low: 1)))
        XCTAssertEqual(serializer2.output.getBuffer(), [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], "the array should be same")

        let serializer3 = BcsSerializer()
        XCTAssertNoThrow(try serializer3.serialize_i128(value: Int128(high: Int64.max, low: UInt64.max)))
        XCTAssertEqual(serializer3.output.getBuffer(), [255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 127], "the array should be same")

        let serializer4 = BcsSerializer()
        XCTAssertNoThrow(try serializer4.serialize_i128(value: Int128(high: Int64.min, low: 0)))
        XCTAssertEqual(serializer4.output.getBuffer(), [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x80], "the array should be same")
    }

    func testULEB128Encoding() throws {
        let serializer = BcsSerializer()
        try serializer.serialize_len(value: 0)
        try serializer.serialize_len(value: 1)
        try serializer.serialize_len(value: 127)
        try serializer.serialize_len(value: 128)
        try serializer.serialize_len(value: 3000)
        XCTAssertEqual(serializer.output.getBuffer(), [0, 1, 127, 128, 1, 184, 23], "the array should be same")
    }
}
