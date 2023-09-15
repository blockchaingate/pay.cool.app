// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multisig_wallet_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MultisigWalletModelAdapter extends TypeAdapter<MultisigWalletModel> {
  @override
  final int typeId = 0;

  @override
  MultisigWalletModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MultisigWalletModel(
      chain: fields[0] as String?,
      name: fields[1] as String?,
      owners: (fields[2] as List?)?.cast<Owners>(),
      confirmations: fields[3] as int?,
      signedRawtx: fields[4] as String?,
      txid: fields[5] as String?,
      address: fields[6] as String?,
      creator: fields[7] as String?,
      status: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MultisigWalletModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.chain)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.owners)
      ..writeByte(3)
      ..write(obj.confirmations)
      ..writeByte(4)
      ..write(obj.signedRawtx)
      ..writeByte(5)
      ..write(obj.txid)
      ..writeByte(6)
      ..write(obj.address)
      ..writeByte(7)
      ..write(obj.creator)
      ..writeByte(8)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultisigWalletModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OwnersAdapter extends TypeAdapter<Owners> {
  @override
  final int typeId = 1;

  @override
  Owners read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Owners(
      name: fields[0] as String?,
      address: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Owners obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.address);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OwnersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
