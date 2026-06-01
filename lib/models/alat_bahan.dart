class AlatBahan {
  int? id;
  int eksperimenId;
  String namaItem;
  int jumlah;
  int isReady;

  AlatBahan({
    this.id,
    required this.eksperimenId,
    required this.namaItem,
    required this.jumlah,
    required this.isReady,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eksperimen_id': eksperimenId,
      'nama_item': namaItem,
      'jumlah': jumlah,
      'is_ready': isReady,
    };
  }

  factory AlatBahan.fromMap(Map<String, dynamic> map) {
    return AlatBahan(
      id: map['id'],
      eksperimenId: map['eksperimen_id'],
      namaItem: map['nama_item'],
      jumlah: map['jumlah'],
      isReady: map['is_ready'],
    );
  }
}
