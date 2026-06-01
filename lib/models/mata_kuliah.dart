class MataKuliah {
  int? id;
  String nama;
  String dosen;
  String semester;
  String warna;

  MataKuliah({
    this.id,
    required this.nama,
    required this.dosen,
    required this.semester,
    required this.warna,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'dosen': dosen,
      'semester': semester,
      'warna': warna,
    };
  }

  factory MataKuliah.fromMap(Map<String, dynamic> map) {
    return MataKuliah(
      id: map['id'],
      nama: map['nama'],
      dosen: map['dosen'],
      semester: map['semester'],
      warna: map['warna'],
    );
  }
}
