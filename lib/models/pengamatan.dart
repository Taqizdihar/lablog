class Pengamatan {
  int? id;
  int eksperimenId;
  String variabel;
  double nilai;
  String satuan;

  Pengamatan({
    this.id,
    required this.eksperimenId,
    required this.variabel,
    required this.nilai,
    required this.satuan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eksperimen_id': eksperimenId,
      'variabel': variabel,
      'nilai': nilai,
      'satuan': satuan,
    };
  }

  factory Pengamatan.fromMap(Map<String, dynamic> map) {
    return Pengamatan(
      id: map['id'],
      eksperimenId: map['eksperimen_id'],
      variabel: map['variabel'],
      nilai: map['nilai'],
      satuan: map['satuan'],
    );
  }
}
