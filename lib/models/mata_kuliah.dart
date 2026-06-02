class MataKuliah {
  int? id;
  String namaMk;
  String dosen;
  String semester;
  String warnaLabel;

  MataKuliah({
    this.id,
    required this.namaMk,
    required this.dosen,
    required this.semester,
    required this.warnaLabel,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_mk': namaMk,
      'dosen': dosen,
      'semester': semester,
      'warna_label': warnaLabel,
    };
  }

  factory MataKuliah.fromMap(Map<String, dynamic> map) {
    return MataKuliah(
      id: map['id'] as int?,
      namaMk: map['nama_mk'] as String,
      dosen: map['dosen'] as String,
      semester: map['semester'] as String,
      warnaLabel: map['warna_label'] as String,
    );
  }
}
