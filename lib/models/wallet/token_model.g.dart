// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TokenModelAdapter extends TypeAdapter<TokenModel> {
  @override
  final int typeId = 4;

  @override
  TokenModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TokenModel(
      decimal: fields[0] as int?,
      coinName: fields[1] as String?,
      tickerName: fields[3] as String?,
      chainName: fields[2] as String?,
      coinType: fields[4] as int?,
      contract: fields[5] as String?,
      minWithdraw: fields[6] as String?,
      feeWithdraw: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TokenModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.decimal)
      ..writeByte(1)
      ..write(obj.coinName)
      ..writeByte(2)
      ..write(obj.chainName)
      ..writeByte(3)
      ..write(obj.tickerName)
      ..writeByte(4)
      ..write(obj.coinType)
      ..writeByte(5)
      ..write(obj.contract)
      ..writeByte(6)
      ..write(obj.minWithdraw)
      ..writeByte(7)
      ..write(obj.feeWithdraw);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
