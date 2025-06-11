# GeneralInformationController

File: `lib/src/features/appointment/controller/post.controller/general_information_controller.dart`

## Deskripsi

`GeneralInformationController` adalah controller utama untuk mengelola form informasi umum pada proses pembuatan post appointment di aplikasi DentaKoas. Controller ini menangani input form, validasi gambar (menggunakan Azure Vision API), upload gambar, serta pengelolaan requirement pasien dan treatment.

---

## Fitur Utama

### 1. **Input Form**

- **title**: Judul post (TextEditingController)
- **description**: Deskripsi post (TextEditingController)
- **requiredParticipant**: Jumlah partisipan yang dibutuhkan (TextEditingController)
- **patientRequirements**: List dinamis untuk requirement pasien (RxList<TextEditingController>)
- **selectedTreatment**: Treatment yang dipilih (RxString)
- **treatmentsMap**: Map ID treatment ke alias (RxMap)

### 2. **Upload & Validasi Gambar**

- **selectedImages**: List file gambar yang dipilih user
- **fileNames**: Nama file unik untuk setiap gambar
- **uploadedUrls**: URL hasil upload (Cloudinary)
- **isUploading**: Status upload gambar
- **analyzingIndex**: Indeks gambar yang sedang divalidasi

#### **Validasi Gambar dengan Azure Vision API**

- Fungsi: `validateDentalImage(File imageFile, int index)`
- Proses:
  1. Kirim gambar ke Azure Vision API (`/vision/v3.2/read/analyze`)
  2. Polling hasil analisis hingga status `succeeded`
  3. Ambil tag dan teks dari hasil analisis
  4. Cek apakah ada kata kunci dental/medis pada tag/teks
  5. Jika tidak ada, tampilkan warning dan tolak gambar

#### **Contoh JSON Response Azure Vision API**

```json
{
  "status": "succeeded",
  "analyzeResult": {
    "tags": [
      { "name": "dental", "confidence": 0.98 },
      { "name": "x-ray", "confidence": 0.95 }
    ],
    "readResults": [
      {
        "lines": [{ "text": "Dental X-Ray" }, { "text": "Patient: John Doe" }]
      }
    ]
  }
}
```

#### **Pengecekan Kata Kunci**

- Semua tag dan teks diubah ke lowercase.
- Dicek apakah ada yang mengandung kata kunci dari `dentalKeywords`.
- Jika ada, gambar valid.

### 3. **Pengelolaan Requirement Pasien**

- Fungsi untuk menambah, menghapus, dan mengambil nilai requirement pasien.
- Validasi agar minimal ada satu requirement.

### 4. **Pengelolaan Treatment**

- Ambil data treatment dari repository.
- Simpan mapping ID dan alias treatment.

### 5. **Pembuatan Post**

- Fungsi: `createGeneralInformation()`
- Validasi form, requirement, dan gambar sebelum lanjut ke tahap berikutnya.

---

## Daftar Fungsi Penting

- `onInit()`: Inisialisasi controller, ambil data treatment.
- `pickImage()`: Pilih gambar dari galeri, validasi, lalu tambahkan ke list.
- `validateDentalImage(File, int)`: Validasi gambar menggunakan Azure Vision API.
- `removeImage(int)`: Hapus gambar dari list.
- `previewImage(BuildContext, File)`: Preview gambar dalam dialog.
- `createGeneralInformation()`: Proses submit form general information.
- `getTreatments()`: Ambil data treatment dari repository.
- `setSelectedTreatment(String)`: Set treatment yang dipilih.
- `buildDropdownItems(Map)`: Generate dropdown item dari map treatment.
- `convertToInt(String)`: Konversi string ke integer.
- `initializeInputs(int)`: Inisialisasi requirement pasien.
- `addInputRequirment()`: Tambah input requirement.
- `removeInputRequirement(int)`: Hapus input requirement.
- `getAllValues()`: Ambil semua nilai requirement.
- `validateRequirements()`: Validasi requirement pasien.

---

## Catatan

- **Azure Vision API** digunakan untuk memastikan gambar yang diupload relevan dengan kesehatan gigi/medis.
- **Cloudinary** dapat digunakan untuk upload gambar setelah validasi (opsional).
- Maksimal 4 gambar dapat diupload.
- Validasi requirement pasien hanya memastikan minimal satu requirement diisi.

---

## Contoh Penggunaan

```dart
final controller = GeneralInformationController.instance;
controller.pickImage(); // Pilih dan validasi gambar
controller.createGeneralInformation(); // Submit form general information
```

---
