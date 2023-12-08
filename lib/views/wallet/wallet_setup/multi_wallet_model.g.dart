// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_wallet_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MultiWalletModelAdapter extends TypeAdapter<MultiWalletModel> {
  @override
  final int typeId = 2;

  @override
  MultiWalletModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MultiWalletModel(
      encryptedMnemonic: fields[0] as String?,
      name: fields[1] as String?,
      isSelected: fields[4] as bool?,
    )
      ..selectedTokens = (fields[2] as List).cast<TokenModel>()
      ..chainAddresses = (fields[3] as List).cast<WalletAddressModel>();
  }

  @override
  void write(BinaryWriter writer, MultiWalletModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.encryptedMnemonic)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.selectedTokens)
      ..writeByte(3)
      ..write(obj.chainAddresses)
      ..writeByte(4)
      ..write(obj.isSelected);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiWalletModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WalletAddressModelAdapter extends TypeAdapter<WalletAddressModel> {
  @override
  final int typeId = 3;

  @override
  WalletAddressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WalletAddressModel(
      tickerName: fields[0] as String?,
      address: fields[1] as String?,
      chain: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WalletAddressModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.tickerName)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.chain);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletAddressModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
