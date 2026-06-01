import 'package:flutter/material.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/models/eksperimen.dart';

class EksperimenFormScreen extends StatefulWidget {
  final Eksperimen? eksperimen;

  const EksperimenFormScreen({super.key, this.eksperimen});

  @override
  State<EksperimenFormScreen> createState() => _EksperimenFormScreenState();
}

class _EksperimenFormScreenState extends State<EksperimenFormScreen> {
  final _formKey = GlobalKey<FormState>();

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.sage),
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: AppColors.bgCard,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Form Eksperimen', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.slate900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: _inputDecoration('Judul Eksperimen'),
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _inputDecoration('Tanggal (YYYY-MM-DD)'),
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _inputDecoration('Tujuan Eksperimen'),
                style: const TextStyle(color: AppColors.textPrimary),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _inputDecoration('Prosedur'),
                style: const TextStyle(color: AppColors.textPrimary),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _inputDecoration('Kesimpulan'),
                style: const TextStyle(color: AppColors.textPrimary),
                maxLines: 2,
              ),
              
              const SizedBox(height: 24),
              const Text(
                'Alat & Bahan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate700,
                ),
              ),
              const SizedBox(height: 12),
              
              // Placeholder ListView for Alat & Bahan Checklist
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final items = ['Mikroskop', 'Gelas Ukur', 'Pipet'];
                    return CheckboxListTile(
                      title: Text(
                        items[index], 
                        style: const TextStyle(color: AppColors.textPrimary)
                      ),
                      value: index == 0, // Mock checked state
                      onChanged: (bool? value) {},
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      activeColor: AppColors.sage,
                      checkColor: Colors.white,
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sage,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // TODO: Save logic connecting to SQLite
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Menyimpan eksperimen...')),
                  );
                },
                child: const Text(
                  'Simpan Eksperimen', 
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
