class LampiranMedia {
  int? id;
  int eksperimenId;
  String filePath;
  String jenisMedia;
  String waktuDiambil;

  LampiranMedia({
    this.id,
    required this.eksperimenId,
    required this.filePath,
    required this.jenisMedia,
    required this.waktuDiambil,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eksperimen_id': eksperimenId,
      'file_path': filePath,
      'jenis_media': jenisMedia,
      'waktu_diambil': waktuDiambil,
    };
  }

  factory LampiranMedia.fromMap(Map<String, dynamic> map) {
    return LampiranMedia(
      id: map['id'],
      eksperimenId: map['eksperimen_id'],
      filePath: map['file_path'],
      jenisMedia: map['jenis_media'],
      waktuDiambil: map['waktu_diambil'],
    );
  }
}
