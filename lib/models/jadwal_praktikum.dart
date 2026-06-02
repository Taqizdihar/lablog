class JadwalPraktikum {
  int? id;
  int mkId;
  String hari;
  String jamMulai;
  String jamSelesai;
  String ruangan;

  JadwalPraktikum({
    this.id,
    required this.mkId,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.ruangan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mk_id': mkId,
      'hari': hari,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'ruangan': ruangan,
    };
  }

  factory JadwalPraktikum.fromMap(Map<String, dynamic> map) {
    return JadwalPraktikum(
      id: map['id'] as int?,
      mkId: map['mk_id'] as int? ?? 0,
      hari: map['hari']?.toString() ?? '',
      jamMulai: map['jam_mulai']?.toString() ?? '',
      jamSelesai: map['jam_selesai']?.toString() ?? '',
      ruangan: map['ruangan']?.toString() ?? '',
    );
  }
}
