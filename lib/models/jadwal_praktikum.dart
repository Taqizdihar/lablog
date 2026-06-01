class JadwalPraktikum {
  int? id;
  int mkId;
  String hari;
  String jamMulai;
  String ruangan;

  JadwalPraktikum({
    this.id,
    required this.mkId,
    required this.hari,
    required this.jamMulai,
    required this.ruangan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mk_id': mkId,
      'hari': hari,
      'jam_mulai': jamMulai,
      'ruangan': ruangan,
    };
  }

  factory JadwalPraktikum.fromMap(Map<String, dynamic> map) {
    return JadwalPraktikum(
      id: map['id'],
      mkId: map['mk_id'],
      hari: map['hari'],
      jamMulai: map['jam_mulai'],
      ruangan: map['ruangan'],
    );
  }
}
