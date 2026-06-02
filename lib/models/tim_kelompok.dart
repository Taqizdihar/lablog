class TimKelompok {
  int? id;
  int mkId;
  String namaAnggota;
  String nim;
  String peran;
  String noHp;

  TimKelompok({
    this.id,
    required this.mkId,
    required this.namaAnggota,
    required this.nim,
    required this.peran,
    required this.noHp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mk_id': mkId,
      'nama_anggota': namaAnggota,
      'nim': nim,
      'peran': peran,
      'no_hp': noHp,
    };
  }

  factory TimKelompok.fromMap(Map<String, dynamic> map) {
    return TimKelompok(
      id: map['id'] as int?,
      mkId: map['mk_id'] as int,
      namaAnggota: map['nama_anggota'] as String,
      nim: map['nim'] as String,
      peran: map['peran'] as String,
      noHp: map['no_hp'] as String,
    );
  }
}
