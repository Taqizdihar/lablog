class Eksperimen {
  int? id;
  int mkId;
  String judul;
  String tanggal;
  String tujuan;
  String alat;
  String prosedur;
  String kesimpulan;

  Eksperimen({
    this.id,
    required this.mkId,
    required this.judul,
    required this.tanggal,
    required this.tujuan,
    required this.alat,
    required this.prosedur,
    required this.kesimpulan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mk_id': mkId,
      'judul': judul,
      'tanggal': tanggal,
      'tujuan': tujuan,
      'alat': alat,
      'prosedur': prosedur,
      'kesimpulan': kesimpulan,
    };
  }

  factory Eksperimen.fromMap(Map<String, dynamic> map) {
    return Eksperimen(
      id: map['id'],
      mkId: map['mk_id'],
      judul: map['judul'],
      tanggal: map['tanggal'],
      tujuan: map['tujuan'],
      alat: map['alat'],
      prosedur: map['prosedur'],
      kesimpulan: map['kesimpulan'],
    );
  }
}
