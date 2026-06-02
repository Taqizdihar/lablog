class Referensi {
  int? id;
  int mkId;
  String judulBuku;
  String penulis;
  String tahunTerbit;
  String tautanSumber;

  Referensi({
    this.id,
    required this.mkId,
    required this.judulBuku,
    required this.penulis,
    required this.tahunTerbit,
    required this.tautanSumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mk_id': mkId,
      'judul_buku': judulBuku,
      'penulis': penulis,
      'tahun_terbit': tahunTerbit,
      'tautan_sumber': tautanSumber,
    };
  }

  factory Referensi.fromMap(Map<String, dynamic> map) {
    return Referensi(
      id: map['id'] as int?,
      mkId: map['mk_id'] as int,
      judulBuku: map['judul_buku'] as String,
      penulis: map['penulis'] as String,
      tahunTerbit: map['tahun_terbit'] as String,
      tautanSumber: map['tautan_sumber'] as String,
    );
  }
}
