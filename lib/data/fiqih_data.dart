/// Data fiqih offline — diambil dari my-ramadhan Next.js project
/// Dilengkapi dengan fiqih umum: thaharah, sholat, zakat, haid, jenazah
final List<Map<String, dynamic>> fiqihOfflineData = [
  // ═══════════════════════════════════════════════════════════════
  //  THAHARAH (BERSUSI)
  // ═══════════════════════════════════════════════════════════════
  {
    'id': '1',
    'title': 'Pengertian Thaharah',
    'content':
        'Thaharah artinya bersuci. Hukumnya wajib sebelum melaksanakan ibadah tertentu seperti shalat. Thaharah mencakup wudhu, mandi, tayammum, dan menghilangkan najis.',
    'category': 'thaharah',
    'reference': 'QS. Al-Maidah: 6',
  },
  {
    'id': '2',
    'title': 'Syarat Sah Wudhu',
    'content':
        '1. Islam\n2. Mumayyiz (dapat membedakan baik buruk)\n3. Air suci dan menyucikan\n4. Tidak ada yang menghalangi air ke kulit (cat, kutek, dll)\n5. Tidak berhadats besar',
    'category': 'thaharah',
    'reference': 'Ijma Ulama',
  },
  {
    'id': '3',
    'title': 'Rukun Wudhu',
    'content':
        '1. Niat\n2. Membasuh wajah\n3. Membasuh kedua tangan sampai siku\n4. Mengusap sebagian kepala\n5. Membasuh kedua kaki sampai mata kaki\n6. Tertib (berurutan)',
    'category': 'thaharah',
    'reference': 'QS. Al-Maidah: 6',
  },
  {
    'id': '4',
    'title': 'Sunnah Wudhu',
    'content':
        '1. Membaca basmalah\n2. Bersiwak (gosok gigi)\n3. Membasuh telapak tangan 3x\n4. Berkumur-kumur\n5. Istinsyaq (menghirup air ke hidung)\n6. Mengusap telinga\n7. Mendahulukan kanan\n8. Membaca doa setelah wudhu',
    'category': 'thaharah',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '5',
    'title': 'Hal yang Membatalkan Wudhu',
    'content':
        '1. Keluar sesuatu dari kubul dan dubur (kencing, BAB, kentut)\n2. Hilang akal (tidur nyenyak, pingsan, mabuk)\n3. Menyentuh kemaluan tanpa penghalang\n4. Menyentuh lawan jenis bukan mahram (tanpa penghalang) — menurut sebagian ulama',
    'category': 'thaharah',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '6',
    'title': 'Tayammum',
    'content':
        'Tayammum adalah pengganti wudhu atau mandi wajib dengan debu yang suci. Dilakukan ketika:\n1. Tidak ada air\n2. Sakit yang tidak boleh kena air\n3. Perjalanan jauh dan air terbatas\nCara: Niat, usap wajah, usap kedua telapak tangan dengan debu.',
    'category': 'thaharah',
    'reference': 'QS. An-Nisa: 43',
  },
  {
    'id': '7',
    'title': 'Mandi Wajib (Ghusl)',
    'content':
        'Mandi wajib dilakukan ketika:\n1. Junub (keluar mani / berhubungan)\n2. Haid berhenti\n3. Nifas berhenti\n4. Masuk Islam\nTata cara: Niat, bersihkan kotoran, basuh seluruh tubuh (rambut hingga ujung kaki).',
    'category': 'thaharah',
    'reference': 'HR. Muslim',
  },
  {
    'id': '8',
    'title': 'Najis Mukhaffafah (Ringan)',
    'content':
        'Contoh: Air kencing bayi laki-laki yang belum makan selain ASI.\nCara membersihkan: Percikkan air secukupnya.',
    'category': 'thaharah',
    'reference': 'HR. Abu Dawud',
  },
  {
    'id': '9',
    'title': 'Najis Mutawassithah (Sedang)',
    'content':
        'Contoh: Darah, nanah, air kencing, kotoran manusia.\nCara membersihkan: Hilangkan zat, warna, bau, dan rasanya.',
    'category': 'thaharah',
    'reference': 'Ijma Ulama',
  },
  {
    'id': '10',
    'title': 'Najis Mughallazhah (Berat)',
    'content':
        'Contoh: Air liur anjing dan babi.\nCara membersihkan: Basuh 7 kali, salah satunya dengan tanah/debu.',
    'category': 'thaharah',
    'reference': 'HR. Muslim',
  },

  // ═══════════════════════════════════════════════════════════════
  //  SHOLAT
  // ═══════════════════════════════════════════════════════════════
  {
    'id': '11',
    'title': 'Kedudukan Shalat',
    'content':
        'Shalat adalah rukun Islam kedua setelah syahadat. Hukumnya wajib ain bagi setiap muslim yang baligh dan berakal. Shalat adalah tiang agama, barangsiapa mendirikannya berarti menegakkan agama.',
    'category': 'sholat',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '12',
    'title': 'Syarat Wajib Shalat',
    'content':
        '1. Islam\n2. Baligh (dewasa)\n3. Berakal\n4. Telah sampai dakwah Islam\n5. Suci dari haid dan nifas',
    'category': 'sholat',
    'reference': 'Ijma Ulama',
  },
  {
    'id': '13',
    'title': 'Syarat Sah Shalat',
    'content':
        '1. Suci dari hadats (kecil & besar)\n2. Suci badan, pakaian, dan tempat dari najis\n3. Menutup aurat\n4. Masuk waktu shalat\n5. Menghadap kiblat',
    'category': 'sholat',
    'reference': 'QS. Al-Maidah: 6',
  },
  {
    'id': '14',
    'title': 'Rukun Shalat',
    'content':
        '1. Niat\n2. Takbiratul ihram\n3. Berdiri bagi yang mampu\n4. Membaca Al-Fatihah\n5. Ruku\'\n6. I\'tidal\n7. Sujud dua kali\n8. Duduk antara dua sujud\n9. Duduk tasyahud akhir\n10. Membaca tasyahud akhir\n11. Membaca shalawat nabi\n12. Salam (pertama)\n13. Tertib (berurutan)',
    'category': 'sholat',
    'reference': 'HR. Bukhari',
  },
  {
    'id': '15',
    'title': 'Waktu Shalat Fardhu',
    'content':
        '1. Shubuh: Fajar hingga matahari terbit\n2. Dhuhur: Matahari bergeser ke barat hingga bayangan sama panjang\n3. Ashar: Bayangan lebih panjang hingga matahari menguning\n4. Maghrib: Matahari terbenam hingga mega merah hilang\n5. Isya: Mega merah hilang hingga fajar shubuh',
    'category': 'sholat',
    'reference': 'HR. Muslim',
  },
  {
    'id': '16',
    'title': 'Sunah Rawatib',
    'content':
        'Shalat sunnah yang mengiringi shalat fardhu:\n1. Qabliyah Shubuh: 2 rakaat\n2. Qabliyah Dhuhur: 2/4 rakaat\n3. Ba\'diyah Dhuhur: 2 rakaat\n4. Ba\'diyah Maghrib: 2 rakaat\n5. Ba\'diyah Isya: 2 rakaat\nKeutamaannya: Dibangunkan rumah di surga.',
    'category': 'sholat',
    'reference': 'HR. Muslim',
  },
  {
    'id': '17',
    'title': 'Shalat Berjamaah',
    'content':
        'Shalat berjamaah lebih utama 27 derajat daripada shalat sendirian. Hukumnya sunnah muakkad bagi laki-laki. Makmum harus mengikuti imam.',
    'category': 'sholat',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '18',
    'title': 'Shalat Jumat',
    'content':
        'Shalat Jumat hukumnya wajib bagi laki-laki muslim yang mukallaf (baligh, berakal, merdeka, dan bermukim). Dilaksanakan 2 rakaat setelah khutbah. Tidak wajib bagi: wanita, anak-anak, orang sakit, musafir.',
    'category': 'sholat',
    'reference': 'QS. Al-Jumuah: 9-10',
  },
  {
    'id': '19',
    'title': 'Shalat Jamak',
    'content':
        'Shalat jamak adalah menggabungkan dua shalat fardhu dalam satu waktu. Dibolehkan bagi musafir.\n1. Jamak Taqdim: Dhuhur + Ashar di waktu Dhuhur, Maghrib + Isya di waktu Maghrib\n2. Jamak Takhir: Dhuhur + Ashar di waktu Ashar, Maghrib + Isya di waktu Isya',
    'category': 'sholat',
    'reference': 'HR. Muslim',
  },
  {
    'id': '20',
    'title': 'Shalat Qashar',
    'content':
        'Shalat qashar adalah meringkas shalat 4 rakaat (Dhuhur, Ashar, Isya) menjadi 2 rakaat. Dilakukan ketika safar perjalanan minimal ±80 km. Tidak boleh diqashar: Shubuh (tetap 2) dan Maghrib (tetap 3).',
    'category': 'sholat',
    'reference': 'QS. An-Nisa: 101',
  },
  {
    'id': '21',
    'title': 'Sujud Sahwi',
    'content':
        'Sujud Sahwi adalah sujud dua kali karena lupa atau ragu dalam shalat. Dilakukan sebelum salam (atau setelah salam menurut sebagian ulama). Sebab: kelebihan, kekurangan, atau keraguan dalam rakaat.',
    'category': 'sholat',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '22',
    'title': 'Sujud Tilawah',
    'content':
        'Sujud Tilawah adalah sujud ketika membaca atau mendengar ayat sajdah dalam Al-Quran. Dilakukan 1 kali sujud dengan takbir, sujud sambil membaca doa, lalu salam. Ada 15 ayat sajdah dalam Al-Quran.',
    'category': 'sholat',
    'reference': 'HR. Bukhari',
  },
  {
    'id': '23',
    'title': 'Shalat Sunnah Tahajud',
    'content':
        'Shalat Tahajud adalah shalat sunnah di malam hari setelah tidur. Hukumnya sunnah muakkad. Minimal 2 rakaat, maksimal tidak terbatas. Waktu: setelah Isya hingga sebelum Shubuh, terutama sepertiga malam terakhir.',
    'category': 'sholat',
    'reference': 'QS. Al-Isra: 79',
  },
  {
    'id': '24',
    'title': 'Shalat Sunnah Dhuha',
    'content':
        'Shalat Dhuha adalah shalat sunnah di waktu pagi setelah matahari naik setinggi tombak hingga menjelang Dhuhur. Minimal 2 rakaat. Keutamaanya: seperti sedekah untuk setiap sendi tubuh dan dicukupkan rezekinya.',
    'category': 'sholat',
    'reference': 'HR. Muslim',
  },
  {
    'id': '25',
    'title': 'Shalat Sunnah Witir',
    'content':
        'Shalat Witir adalah shalat penutup malam dengan jumlah rakaat ganjil (1, 3, 5, 7, 9, 11). Biasanya dilakukan setelah shalat Isya atau setelah Tahajud. Rasulullah tidak pernah meninggalkan witir.',
    'category': 'sholat',
    'reference': 'HR. Bukhari & Muslim',
  },

  // ═══════════════════════════════════════════════════════════════
  //  PUASA (Eksisting + Tambahan)
  // ═══════════════════════════════════════════════════════════════
  {
    'id': '26',
    'title': 'Kewajiban Puasa Ramadhan',
    'content':
        'Puasa Ramadhan wajib bagi setiap muslim yang baligh, berakal, dan mampu menjalankannya.',
    'category': 'puasa',
    'reference': 'QS. Al-Baqarah: 183',
  },
  {
    'id': '27',
    'title': 'Niat Puasa Ramadhan',
    'content':
        'Niat puasa Ramadhan termasuk rukun puasa yang wajib dilakukan setiap malam di bulan Ramadhan. Niat cukup di dalam hati, namun disunnahkan melafalkannya.',
    'category': 'puasa',
    'reference': 'HR. Abu Dawud',
  },
  {
    'id': '28',
    'title': 'Hal-hal yang Membatalkan Puasa',
    'content':
        '1. Makan dan minum dengan sengaja\n2. Muntah dengan sengaja\n3. Haid dan nifas\n4. Keluar air mani dengan sengaja\n5. Gila\n6. Murtad (keluar dari Islam)\n7. Berhubungan suami istri di siang hari',
    'category': 'puasa',
    'reference': 'Ijma Ulama',
  },
  {
    'id': '29',
    'title': 'Waktu Puasa',
    'content':
        'Puasa dimulai dari terbit fajar (Subuh) hingga terbenam matahari (Maghrib). Imsak bukan awal puasa, awal puasa adalah terbit fajar.',
    'category': 'puasa',
    'reference': 'QS. Al-Baqarah: 187',
  },
  {
    'id': '30',
    'title': 'Sunnah Puasa',
    'content':
        '1. Makan sahur\n2. Mengakhirkan sahur\n3. Menyegerakan berbuka\n4. Berbuka dengan kurma atau air\n5. Membaca doa berbuka\n6. Memperbanyak sedekah\n7. I\'tikaf di masjid\n8. Memperbanyak membaca Al-Qur\'an',
    'category': 'puasa',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '31',
    'title': 'Orang yang Diperbolehkan Tidak Puasa',
    'content':
        '1. Sakit: boleh tidak puasa, wajib qadha\n2. Musafir (perjalanan jauh): boleh tidak puasa, wajib qadha\n3. Lansia / sakit permanen: wajib fidyah\n4. Hamil & menyusui (khawatir): qadha + fidyah menurut sebagian ulama',
    'category': 'puasa',
    'reference': 'QS. Al-Baqarah: 184',
  },
  {
    'id': '32',
    'title': 'Fidyah',
    'content':
        'Orang yang tidak mampu berpuasa secara permanen (lansia, sakit menahun) wajib membayar fidyah dengan memberi makan orang miskin. Besarnya 1 mud (sekitar 0,7 kg) makanan pokok per hari.',
    'category': 'puasa',
    'reference': 'QS. Al-Baqarah: 184',
  },
  {
    'id': '33',
    'title': 'Qadha Puasa',
    'content':
        'Puasa yang ditinggalkan wajib diganti sebelum datang Ramadhan berikutnya. Qadha tidak wajib berturut-turut.',
    'category': 'puasa',
    'reference': 'HR. Muslim',
  },
  {
    'id': '34',
    'title': 'Kafarat',
    'content':
        'Berhubungan suami istri di siang Ramadhan mewajibkan qadha dan kafarat: memerdekakan budak, atau puasa 2 bulan berturut-turut, atau memberi makan 60 fakir miskin.',
    'category': 'puasa',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '35',
    'title': 'Puasa Sunnah',
    'content':
        'Puasa sunnah yang dianjurkan:\n1. Puasa 6 hari Syawal\n2. Puasa Arafah (9 Dzulhijjah)\n3. Puasa Asyura (10 Muharram)\n4. Puasa Senin-Kamis\n5. Puasa Daud (selang-seling)\n6. Puasa Sya\'ban (sebanyak-banyaknya)\n7. Puasa awal Dzulhijjah (1-9)',
    'category': 'puasa',
    'reference': 'HR. Muslim',
  },
  {
    'id': '36',
    'title': 'Makan karena Lupa',
    'content':
        'Jika seseorang makan atau minum karena lupa saat berpuasa, maka puasanya tetap sah dan tidak wajib qadha.',
    'category': 'puasa',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '37',
    'title': 'Menelan Ludah & Dahak',
    'content':
        'Menelan ludah sendiri tidak membatalkan puasa. Menelan dahak diperselisihkan ulama, sebaiknya dikeluarkan.',
    'category': 'puasa',
    'reference': 'Kesepakatan Ulama',
  },
  {
    'id': '38',
    'title': 'Suntikan & Infus',
    'content':
        'Suntikan yang tidak mengandung nutrisi tidak membatalkan puasa. Infus yang bersifat mengenyangkan membatalkan puasa.',
    'category': 'puasa',
    'reference': 'Fatwa Ulama Kontemporer',
  },
  {
    'id': '39',
    'title': 'Mimpi Basah',
    'content': 'Mimpi basah tidak membatalkan puasa, namun wajib mandi junub.',
    'category': 'puasa',
    'reference': 'Ijma Ulama',
  },
  {
    'id': '40',
    'title': 'Menggosok Gigi Saat Puasa',
    'content':
        'Bersiwak atau menggosok gigi tidak membatalkan puasa selama tidak menelan sesuatu.',
    'category': 'puasa',
    'reference': 'HR. Bukhari',
  },
  {
    'id': '41',
    'title': 'Sholat Tarawih',
    'content':
        'Sholat Tarawih adalah sholat sunnah yang dikerjakan pada malam hari di bulan Ramadhan. Hukumnya sunnah muakkad. Bisa 8 atau 20 rakaat (plus 3 witir), setiap 2 rakaat salam.',
    'category': 'sholat',
    'reference': 'HR. Bukhari & Muslim',
  },

  // ═══════════════════════════════════════════════════════════════
  //  ZAKAT
  // ═══════════════════════════════════════════════════════════════
  {
    'id': '42',
    'title': 'Pengertian Zakat',
    'content':
        'Zakat adalah rukun Islam keempat. Hukumnya wajib bagi setiap muslim yang memenuhi syarat. Zakat membersihkan harta dan jiwa.',
    'category': 'zakat',
    'reference': 'QS. At-Taubah: 103',
  },
  {
    'id': '43',
    'title': 'Syarat Wajib Zakat',
    'content':
        '1. Islam\n2. Merdeka (bukan budak)\n3. Kepemilikan harta sempurna\n4. Mencapai nishab (batas minimal harta)\n5. Mencapai haul (masa kepemilikan 1 tahun Hijriah) — khusus zakat maal',
    'category': 'zakat',
    'reference': 'Ijma Ulama',
  },
  {
    'id': '44',
    'title': 'Zakat Fitrah',
    'content':
        'Zakat Fitrah adalah zakat yang wajib dikeluarkan oleh setiap muslim yang mampu pada bulan Ramadhan. Besarnya 1 sha\' (sekitar 2,5 kg) makanan pokok. Waktu: wajib sejak maghrib malam Id hingga sebelum shalat Id.',
    'category': 'zakat',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '45',
    'title': 'Zakat Emas & Perak',
    'content':
        'Zakat emas dan perak wajib jika mencapai nishab:\n- Nishab emas: 85 gram, kadar 2,5%\n- Nishab perak: 595 gram, kadar 2,5%\nDikeluarkan setiap tahun (haul).',
    'category': 'zakat',
    'reference': 'HR. Muslim',
  },
  {
    'id': '46',
    'title': 'Zakat Maal (Harta)',
    'content':
        'Zakat maal mencakup semua harta yang memenuhi syarat: emas, perak, uang, tabungan, investasi, dan aset produktif. Nishab setara 85 gram emas. Kadar 2,5% per tahun.',
    'category': 'zakat',
    'reference': 'QS. At-Taubah: 103',
  },
  {
    'id': '47',
    'title': 'Zakat Penghasilan/Profesi',
    'content':
        'Zakat penghasilan (profesi) dikeluarkan dari pendapatan rutin seperti gaji, honor, atau upah. Nishab setara 85 gram emas. Kadar 2,5%. Dapat dibayarkan setiap bulan atau setiap tahun.',
    'category': 'zakat',
    'reference': 'Fatwa MUI',
  },
  {
    'id': '48',
    'title': 'Zakat Pertanian',
    'content':
        'Zakat pertanian dikeluarkan saat panen. Nishab: 5 wasaq (sekitar 653 kg). Kadar:\n- 10% jika irigasi tadah hujan (alami)\n- 5% jika irigasi berbayar',
    'category': 'zakat',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '49',
    'title': 'Zakat Perniagaan',
    'content':
        'Zakat perniagaan dihitung dari aset dagang (barang + uang) setelah dikurangi utang. Nishab setara 85 gram emas. Kadar 2,5% per tahun.',
    'category': 'zakat',
    'reference': 'HR. Abu Dawud',
  },
  {
    'id': '50',
    'title': '8 Golongan Penerima Zakat (Mustahik)',
    'content':
        '1. Fakir — tidak punya harta dan penghasilan\n2. Miskin — punya harta tapi tidak cukup\n3. Amil — pengelola zakat\n4. Mualaf — orang yang baru masuk Islam\n5. Riqab — budak/mukatab\n6. Gharim — orang yang terlilit utang\n7. Fisabilillah — pejuang di jalan Allah\n8. Ibnu Sabil — musafir yang kehabisan bekal',
    'category': 'zakat',
    'reference': 'QS. At-Taubah: 60',
  },
  {
    'id': '51',
    'title': 'Hukum Tidak Membayar Zakat',
    'content':
        'Orang yang mampu tetapi tidak membayar zakat karena bakhil/kikir berdosa besar. Di akhirat hartanya akan menjadi azab baginya. Pemerintah Islam wajib memungut zakat.',
    'category': 'zakat',
    'reference': 'QS. At-Taubah: 34-35',
  },

  // ═══════════════════════════════════════════════════════════════
  //  HAID, NIFAS & ISTIHADHAH
  // ═══════════════════════════════════════════════════════════════
  {
    'id': '52',
    'title': 'Niat Mandi Wajib',
    'content':
        '"Nawaitu ghusla lifadlil janabah/janabati lillahi ta\'ala" — Aku berniat mandi wajib untuk menghilangkan hadats besar karena Allah Ta\'ala.',
    'category': 'haid',
    'reference': 'Fiqih Thaharah',
  },
  {
    'id': '53',
    'title': 'Ketentuan Haid',
    'content':
        'Haid adalah darah alami yang keluar dari rahim wanita setiap bulan. Minimal masa haid: 24 jam. Maksimal: 15 hari. Umumnya: 6-7 hari. Wanita haid dilarang shalat, puasa, membaca Al-Quran, menyentuh mushaf, dan berhubungan intim.',
    'category': 'haid',
    'reference': 'HR. Bukhari',
  },
  {
    'id': '54',
    'title': 'Nifas',
    'content':
        'Nifas adalah darah yang keluar setelah melahirkan. Umumnya 40 hari, maksimal 60 hari. Ketentuannya sama seperti haid: tidak boleh shalat, puasa, dan berhubungan.',
    'category': 'haid',
    'reference': 'HR. Abu Dawud',
  },
  {
    'id': '55',
    'title': 'Istihadhah',
    'content':
        'Istihadhah adalah darah penyakit yang keluar dari rahim di luar waktu haid/nifas atau melebihi batas maksimal. Wanita istihadhah tetap wajib shalat dan puasa. Cukup berwudhu setiap masuk waktu shalat.',
    'category': 'haid',
    'reference': 'HR. Bukhari',
  },
  {
    'id': '56',
    'title': 'Perbedaan Darah Wanita',
    'content':
        '1. Darah Haid: Warna hitam/merah pekat, kental, berbau khas. Keluar rutin sesuai siklus.\n2. Darah Nifas: Keluar setelah melahirkan.\n3. Darah Istihadhah: Warna merah cerah, encer, tidak berbau. Keluar di luar siklus atau melebihi 15 hari.',
    'category': 'haid',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '57',
    'title': 'Wanita Haid dan Ibadah',
    'content':
        'Wanita yang haid:\n1. Tidak boleh shalat (dan tidak perlu qadha)\n2. Tidak boleh puasa (wajib qadha setelah Ramadhan)\n3. Tidak boleh membaca Al-Quran (menurut sebagian ulama)\n4. Tidak boleh menyentuh mushaf Al-Quran\n5. Boleh berdzikir dan berdoa.',
    'category': 'haid',
    'reference': 'HR. Muslim',
  },

  // ═══════════════════════════════════════════════════════════════
  //  JENAZAH
  // ═══════════════════════════════════════════════════════════════
  {
    'id': '58',
    'title': 'Hukum Mengurus Jenazah',
    'content':
        'Mengurus jenazah muslim hukumnya fardhu kifayah (kewajiban kolektif). Jika sudah ada yang melaksanakan, gugur kewajiban yang lain. Urutan: memandikan, mengkafani, menshalatkan, menguburkan.',
    'category': 'jenazah',
    'reference': 'HR. Muslim',
  },
  {
    'id': '59',
    'title': 'Memandikan Jenazah',
    'content':
        'Tata cara memandikan jenazah:\n1. Tutupi auratnya\n2. Bersihkan kotoran yang keluar\n3. Wudhukan jenazah\n4. Basuh seluruh tubuh (sunnah dengan air bidara/kapur barus)\n5. Bilas ganjil (3x, 5x, atau 7x)\nPetugas: Laki-laki untuk laki-laki, perempuan untuk perempuan, suami/istri diperbolehkan.',
    'category': 'jenazah',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '60',
    'title': 'Mengkafani Jenazah',
    'content':
        '1. Laki-laki: 3 lapis kain kafan putih (tidak perlu gamis dan sorban)\n2. Perempuan: 5 lapis (kemeja, penutup kepala, sarung/kain bawah, 2 lapis pembungkus)\nKain kafan sunnah berwarna putih dan dari bahan sederhana.',
    'category': 'jenazah',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '61',
    'title': 'Shalat Jenazah',
    'content':
        'Rukun shalat jenazah:\n1. Niat\n2. Takbir 4 kali\n3. Takbir ke-1: baca Al-Fatihah\n4. Takbir ke-2: baca shalawat nabi\n5. Takbir ke-3: doa untuk jenazah\n6. Takbir ke-4: doa penutup\n7. Salam\nTidak ada ruku\', sujud, dan tasyahud.',
    'category': 'jenazah',
    'reference': 'HR. Muslim',
  },
  {
    'id': '62',
    'title': 'Doa Shalat Jenazah',
    'content':
        'Setelah takbir ke-3: "Allahummaghfir lahu warhamhu wa \'afihi wa\'fu anhu..." (untuk laki-laki). Untuk perempuan: ganti "hu" dengan "ha". Untuk banyak: "Allahummaghfir lahum warhamhum wa\'fi him wa\'fu anhum."',
    'category': 'jenazah',
    'reference': 'HR. Muslim',
  },
  {
    'id': '63',
    'title': 'Menguburkan Jenazah',
    'content':
        '1. Galian lubang sedalam mungkin\n2. Jenazah dimiringkan menghadap kiblat (rusuk kanan)\n3. Lepaskan ikatan kain kafan\n4. Masukkan dengan pelan dan lembut\n5. Tutup dengan papan/tanah\n6. Disunnahkan meninggikan makam setinggi 1 jengkal.',
    'category': 'jenazah',
    'reference': 'HR. Muslim',
  },
  {
    'id': '64',
    'title': 'Takziah & Ta\'ziyah',
    'content':
        'Takziah adalah menjenguk keluarga yang terkena musibah kematian. Dianjurkan:\n1. Mengucapkan "Inna lillahi wa inna ilaihi raji\'un"\n2. Mendoakan mayat dan keluarga\n3. Memberi makanan kepada keluarga yang berduka\nTidak boleh meratapi mayat dengan berteriak.',
    'category': 'jenazah',
    'reference': 'HR. Abu Dawud',
  },

  // ═══════════════════════════════════════════════════════════════
  //  AMALAN RAMADHAN (Eksisting)
  // ═══════════════════════════════════════════════════════════════
  {
    'id': '65',
    'title': 'I\'tikaf',
    'content':
        'I\'tikaf adalah berdiam diri di masjid dengan niat mendekatkan diri kepada Allah. Disunnahkan terutama di 10 malam terakhir Ramadhan.',
    'category': 'amalan',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '66',
    'title': 'Lailatul Qadar',
    'content':
        'Lailatul Qadar (Malam Kemuliaan) lebih baik dari 1000 bulan. Terjadi pada 10 malam terakhir Ramadhan, terutama pada malam-malam ganjil.',
    'category': 'amalan',
    'reference': 'QS. Al-Qadr: 3',
  },
  {
    'id': '67',
    'title': 'Memberi Makan Orang Berpuasa',
    'content':
        'Barangsiapa memberi makan orang yang berpuasa, ia mendapat pahala seperti orang yang berpuasa tersebut.',
    'category': 'amalan',
    'reference': 'HR. Tirmidzi',
  },
  {
    'id': '68',
    'title': 'Kedermawanan di Ramadhan',
    'content':
        'Rasulullah adalah manusia paling dermawan, dan beliau lebih dermawan lagi di bulan Ramadhan.',
    'category': 'amalan',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '69',
    'title': 'Puasa dan Al-Qur\'an Memberi Syafaat',
    'content':
        'Puasa dan Al-Qur\'an akan memberi syafaat bagi seorang hamba pada hari kiamat.',
    'category': 'amalan',
    'reference': 'HR. Ahmad',
  },
  {
    'id': '70',
    'title': 'Keutamaan Ramadhan',
    'content':
        'Awal Ramadhan adalah rahmat, pertengahannya ampunan, dan akhirnya pembebasan dari neraka.',
    'category': 'amalan',
    'reference': 'HR. Baihaqi',
  },
  {
    'id': '71',
    'title': 'Doa Orang Berpuasa',
    'content':
        'Ada tiga doa yang tidak tertolak: doa orang yang berpuasa, doa pemimpin yang adil, dan doa orang yang terzalimi.',
    'category': 'doa',
    'reference': 'HR. Tirmidzi',
  },
  {
    'id': '72',
    'title': 'Doa Berbuka Puasa',
    'content':
        '"Allahumma laka shumtu wa bika amantu wa \'ala rizqika afthartu, birrahmatika ya arhamar rahimin"',
    'category': 'doa',
    'reference': 'HR. Abu Dawud',
  },
  {
    'id': '73',
    'title': 'Keutamaan Tarawih Berjamaah',
    'content':
        'Barangsiapa shalat bersama imam sampai selesai, dicatat baginya pahala seperti shalat semalam penuh.',
    'category': 'sholat',
    'reference': 'HR. Abu Dawud & Tirmidzi',
  },

  // ═══════════════════════════════════════════════════════════════
  //  MUAMALAH (Jual Beli, Riba, Hutang, Gadai, Sewa)
  // ═══════════════════════════════════════════════════════════════
  {
    'id': '74',
    'title': 'Hukum Jual Beli dalam Islam',
    'content':
        'Jual beli (al-bay\') hukumnya mubah (boleh) dan termasuk aktivitas yang diberkahi jika dilakukan secara jujur dan terbuka. Dilarang: jual beli barang haram, tipu-menipu, gharar (ketidakjelasan), dan riba.',
    'category': 'muamalah',
    'reference': 'QS. Al-Baqarah: 275',
  },
  {
    'id': '75',
    'title': 'Rukun Jual Beli',
    'content':
        '1. Penjual dan pembeli (aqid)\n2. Sighat (ijab dan qabul)\n3. Ma\'qud \'alaih (barang dan harga)\nSyarat: baligh, berakal, atas kemauan sendiri, barang milik sah, dapat diserahkan, jelas spesifikasinya.',
    'category': 'muamalah',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '76',
    'title': 'Pengertian Riba',
    'content':
        'Riba secara bahasa artinya tambahan. Secara syariat: tambahan tanpa imbalan dalam transaksi utang piutang atau jual beli. Riba termasuk dosa besar dan hukumnya haram.',
    'category': 'muamalah',
    'reference': 'QS. Al-Baqarah: 275-279',
  },
  {
    'id': '77',
    'title': 'Jenis-jenis Riba',
    'content':
        '1. Riba Fadhl: tukar menukar barang sejenis dengan takaran/timbangan berbeda\n2. Riba Nasi\'ah: tambahan karena penangguhan waktu pembayaran\n3. Riba Qardh: mengambil manfaat dari uang yang dipinjamkan\nSetiap utang yang mengambil manfaat adalah riba.',
    'category': 'muamalah',
    'reference': 'HR. Muslim no. 1584',
  },
  {
    'id': '78',
    'title': 'Hutang Piutang (Qardh)',
    'content':
        'Hutang piutang hukumnya boleh (mubah) dan dianjurkan untuk membantu sesama. Pemberi utang tidak boleh meminta imbalan/tambahan. Jika memberikan tambahan secara sukarela tanpa diminta, diperbolehkan. Utang wajib dibayar.',
    'category': 'muamalah',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '79',
    'title': 'Gadai (Rahn)',
    'content':
        'Gadai adalah menjadikan barang sebagai jaminan utang. Hukumnya boleh. Pemberi utang tidak boleh mengambil manfaat dari barang gadai karena termasuk riba. Kecuali hewan tunggangan/susu yang boleh dimanfaatkan sebatas biaya perawatan. Jika jatuh tempo, pemberi utang boleh menjual barang gadai untuk melunasi utang.',
    'category': 'muamalah',
    'reference': 'Rumaysho.com/2318',
  },
  {
    'id': '80',
    'title': 'Sewa-Menyewa (Ijarah)',
    'content':
        'Sewa-menyewa (ijarah) hukumnya boleh. Rukun: musta\'jir (penyewa), mu\'jir (pemilik), ma\'jur (barang/aset), ujrah (upah/harga sewa). Kedua pihak harus jelas spesifikasinya dan rela sama rela.',
    'category': 'muamalah',
    'reference': 'QS. Ath-Thalaq: 6',
  },
  {
    'id': '81',
    'title': 'Khiyar (Hak Memilih dalam Jual Beli)',
    'content':
        'Khiyar adalah hak untuk melanjutkan atau membatalkan transaksi. Macam:\n1. Khiyar Majlis: hak pilih selama masih di tempat akad\n2. Khiyar Syarat: hak pilih dalam waktu yang disepakati\n3. Khiyar \'Aib: hak pilih jika barang cacat',
    'category': 'muamalah',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '82',
    'title': 'Larangan Gharar (Ketidakjelasan)',
    'content':
        'Gharar adalah transaksi yang mengandung ketidakjelasan/risiko. Contoh: menjual ikan dalam laut, burung di udara, janin dalam kandungan. Hukumnya haram karena dapat merugikan salah satu pihak.',
    'category': 'muamalah',
    'reference': 'HR. Muslim no. 1513',
  },
  {
    'id': '83',
    'title': 'Jual Beli yang Dilarang',
    'content':
        '1. Jual beli barang najis (babi, khamr, bangkai)\n2. Jual beli dengan tipuan (ghisy)\n3. Jual beli barang yang belum dimiliki (qabla al-qabdhi)\n4. Jual beli najasy (menawar palsu)\n5. Jual beli dengan sistem maysir (judi/undi)',
    'category': 'muamalah',
    'reference': 'HR. Bukhari & Muslim',
  },

  // ═══════════════════════════════════════════════════════════════
  //  PERNIKAHAN (Nikah, Mahar, Talak, Iddah, Rujuk)
  // ═══════════════════════════════════════════════════════════════
  {
    'id': '84',
    'title': 'Pengertian Nikah',
    'content':
        'Nikah adalah akad yang menghalalkan pergaulan dan hubungan suami istri. Hukum asal nikah adalah sunnah. Bisa menjadi wajib jika dikhawatirkan terjerumus zina. Nikah adalah sunnah para rasul.',
    'category': 'nikah',
    'reference': 'QS. An-Nur: 32',
  },
  {
    'id': '85',
    'title': 'Syarat dan Rukun Nikah',
    'content':
        'Rukun nikah:\n1. Calon suami\n2. Calon istri\n3. Wali\n4. Dua saksi laki-laki\n5. Sighat (ijab qabul)\nSyarat: baligh, berakal, tidak ada halangan syar\'i (seperti mahram, beda agama), atas kemauan sendiri, wali yang sah.',
    'category': 'nikah',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '86',
    'title': 'Mahar (Maskawin)',
    'content':
        'Mahar adalah pemberian wajib dari suami kepada istri sebagai simbol kesungguhan. Tidak ada batas minimal/maksimal, namun dianjurkan sederhana dan tidak memberatkan. Mahar menjadi hak penuh istri.',
    'category': 'nikah',
    'reference': 'QS. An-Nisa: 4',
  },
  {
    'id': '87',
    'title': 'Walimah (Resepsi Pernikahan)',
    'content':
        'Walimah adalah jamuan makan dalam rangka pernikahan. Hukumnya sunnah muakkad. Disunnahkan mengundang orang shalih, kaya dan miskin. Tidak boleh berlebihan (israf). Waktu: setelah akad nikah.',
    'category': 'nikah',
    'reference': 'HR. Bukhari no. 5179',
  },
  {
    'id': '88',
    'title': 'Pengertian Talak',
    'content':
        'Talak adalah melepaskan ikatan pernikahan dengan lafaz tertentu. Hukum asal makruh, bisa menjadi wajib/haram tergantung situasi. Talak ada dua: Talak Sharih (lafaz jelas, butuh niat) dan Talak Kinayah (kiasan, butuh niat).',
    'category': 'nikah',
    'reference': 'Rumaysho.com/41904',
  },
  {
    'id': '89',
    'title': 'Jenis-jenis Talak',
    'content':
        '1. Talak Raj\'i: talak satu/dua, suami boleh rujuk dalam masa iddah tanpa akad baru\n2. Talak Bain: talak yang tidak boleh rujuk kecuali dengan akad baru. Terbagi:\n   - Bain Sughra: talak satu/dua setelah habis iddah\n   - Bain Kubra: talak tiga (harus ada muhallil)\n3. Talak Sunnah: talak saat istri suci dan tidak digauli\n4. Talak Bid\'ah: talak saat haid atau saat suci tapi sudah digauli',
    'category': 'nikah',
    'reference': 'HR. Muslim',
  },
  {
    'id': '90',
    'title': 'Iddah',
    'content':
        'Iddah adalah masa tunggu wanita setelah talak atau kematian suami:\n1. Wanita hamil: hingga melahirkan\n2. Wanita haid: 3 kali suci (quru\')\n3. Wanita menopause/tidak haid: 3 bulan\n4. Istri yang ditinggal mati: 4 bulan 10 hari',
    'category': 'nikah',
    'reference': 'QS. Al-Baqarah: 228, 234',
  },
  {
    'id': '91',
    'title': 'Rujuk',
    'content':
        'Rujuk adalah kembalinya suami kepada istri dalam masa iddah tanpa akad baru. Hukumnya boleh selama talak belum tiga. Syarat: suami muslim, istri masih dalam iddah talak raj\'i, ada kerelaan. Jika sudah talak tiga, tidak boleh rujuk kecuali istri menikah dengan pria lain dan bercerai secara sah.',
    'category': 'nikah',
    'reference': 'QS. Al-Baqarah: 228-230',
  },
  {
    'id': '92',
    'title': 'Khulu\' (Gugat Cerai Istri)',
    'content':
        'Khulu\' adalah perceraian atas permintaan istri dengan membayar tebusan (iwadh). Hukumnya boleh jika istri tidak mau lagi bersuamikan suaminya. Setelah khulu\', suami tidak boleh rujuk kecuali dengan akad baru.',
    'category': 'nikah',
    'reference': 'HR. Bukhari no. 5273',
  },
  {
    'id': '93',
    'title': 'Hukum Melamar (Khithbah)',
    'content':
        'Melamar hukumnya boleh sebelum akad. Tidak boleh meminang perempuan yang sudah dipinang orang lain. Melamar boleh melihat wajah dan telapak tangan calon. Jika lamaran diterima, disunnahkan shalat istikharah.',
    'category': 'nikah',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '94',
    'title': 'Hak dan Kewajiban Suami Istri',
    'content':
        'Suami wajib: memberi nafkah lahir batin (makan, pakaian, tempat tinggal), menggauli dengan baik, memberikan mahar, dan memimpin keluarga.\nIstri wajib: taat kepada suami dalam kebaikan, menjaga kehormatan, mengatur rumah tangga.\nSaling: berlaku baik, saling menghormati, dan bermusyawarah.',
    'category': 'nikah',
    'reference': 'QS. An-Nisa: 34, At-Thalaq: 6',
  },

  // ═══════════════════════════════════════════════════════════════
  //  KURBAN & AQIQAH
  // ═══════════════════════════════════════════════════════════════
  {
    'id': '95',
    'title': 'Pengertian Kurban',
    'content':
        'Kurban (udhiyah) adalah menyembelih hewan ternak pada hari raya Idul Adha (10 Dzulhijjah) dan hari tasyrik (11-13 Dzulhijjah). Hukumnya sunnah muakkad bagi yang mampu.',
    'category': 'kurban',
    'reference': 'QS. Al-Kautsar: 2',
  },
  {
    'id': '96',
    'title': 'Syarat Hewan Kurban',
    'content':
        '1. Hewan ternak: unta, sapi, kerbau, kambing, domba\n2. Cukup umur:\n   - Unta: 5 tahun\n   - Sapi/kerbau: 2 tahun\n   - Kambing/domba: 1 tahun (domba boleh 6 bulan jika besar)\n3. Tidak cacat: buta, pincang, sakit, kurus, patah tanduk\n4. Sapi/kerbau untuk 7 orang, kambing/domba untuk 1 orang',
    'category': 'kurban',
    'reference': 'HR. Muslim no. 1318',
  },
  {
    'id': '97',
    'title': 'Tata Cara Penyembelihan Kurban',
    'content':
        '1. Niat karena Allah\n2. Membaca basmalah\n3. Membaca takbir 3x dan tahmid 1x\n4. Membaca doa: "Allahumma hadza minka wa laka"\n5. Menyembelih dengan pisau tajam\n6. Menghadap kiblat (hewan dan orang yang menyembelih)\nWaktu: setelah shalat Idul Adha hingga terbenam matahari 13 Dzulhijjah.',
    'category': 'kurban',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '98',
    'title': 'Pembagian Daging Kurban',
    'content':
        '1. Sepertiga untuk yang berkurban dan keluarganya\n2. Sepertiga untuk tetangga dan kerabat\n3. Sepertiga untuk fakir miskin\nTidak boleh dijual. Kulit kurban boleh dimanfaatkan atau disedekahkan. Tidak boleh memberi upah penyembelih dari daging kurban.',
    'category': 'kurban',
    'reference': 'QS. Al-Hajj: 28',
  },
  {
    'id': '99',
    'title': 'Pengertian Aqiqah',
    'content':
        'Aqiqah adalah penyembelihan hewan untuk anak yang baru lahir sebagai tanda syukur. Hukumnya sunnah muakkad. Dilaksanakan pada hari ke-7 setelah kelahiran. Untuk anak laki-laki: 2 kambing, perempuan: 1 kambing.',
    'category': 'kurban',
    'reference': 'HR. Abu Dawud no. 2843',
  },
  {
    'id': '100',
    'title': 'Tata Cara Aqiqah',
    'content':
        '1. Dilaksanakan hari ke-7 setelah kelahiran\n2. Boleh diundur jika belum mampu\n3. Daging dimasak manis dan dibagikan kepada tetangga, kerabat, dan fakir miskin\n4. Sunnah mencukur rambut bayi, memberi nama, dan bersedekah seberat rambut (perak)\n5. Tidak boleh memecah tulang hewan aqiqah',
    'category': 'kurban',
    'reference': 'HR. Tirmidzi no. 1522',
  },

  // ═══════════════════════════════════════════════════════════════
  //  SHALAT KHUSUS (Gerhana, Istisqa, Istikharah, Hajat, Tahajud)
  // ═══════════════════════════════════════════════════════════════
  {
    'id': '101',
    'title': 'Shalat Gerhana (Kusuf & Khusuf)',
    'content':
        'Shalat gerhana hukumnya sunnah muakkad. Gerhana matahari disebut kusuf, gerhana bulan disebut khusuf. Cara: 2 rakaat, setiap rakaat 2 kali berdiri (qiyam) dan 2 kali rukuk. Setelah shalat, disunnahkan khutbah 2 kali untuk bertaubat dan bersedekah.',
    'category': 'sholat',
    'reference': 'Rumaysho.com/42076',
  },
  {
    'id': '102',
    'title': 'Perbedaan Gerhana Matahari & Bulan',
    'content':
        '1. Shalat gerhana matahari: bacaan pelan (sirr)\n2. Shalat gerhana bulan: bacaan keras (jahr)\n3. Keduanya tidak perlu diqadha jika terlewat\n4. Jumlah rakaat gerhana: minimal 2 rakaat dengan cara biasa, paling utama: 2 rakaat dengan 2 kali qiyam dan 2 kali rukuk setiap rakaat.',
    'category': 'sholat',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '103',
    'title': 'Shalat Istisqa (Minta Hujan)',
    'content':
        'Shalat Istisqa adalah shalat sunnah untuk meminta hujan ketika kemarau panjang. Dilaksanakan di tanah lapang. 2 rakaat dengan bacaan keras. Setelah shalat: khutbah, berdoa memohon hujan, dan bertakbir. Disunnahkan berpakaian sederhana dan bertobat.',
    'category': 'sholat',
    'reference': 'HR. Bukhari no. 1005',
  },
  {
    'id': '104',
    'title': 'Shalat Istikharah',
    'content':
        'Shalat Istikharah adalah shalat sunnah 2 rakaat untuk memohon petunjuk kebaikan dalam suatu urusan. Dilakukan ketika ragu memilih antara dua atau lebih pilihan. Setelah shalat membaca doa istikharah. Hasil: hati menjadi mantap pada salah satu pilihan.',
    'category': 'sholat',
    'reference': 'HR. Bukhari no. 1162',
  },
  {
    'id': '105',
    'title': 'Shalat Hajat',
    'content':
        'Shalat Hajat adalah shalat sunnah untuk memohon kepada Allah agar suatu kebutuhan dikabulkan. Dilakukan 2-12 rakaat, setiap 2 rakaat salam. Waktu: kapan saja kecuali waktu terlarang. Dianjurkan membaca ayat Kursi dan doa khusus.',
    'category': 'sholat',
    'reference': 'HR. Tirmidzi no. 569',
  },
  {
    'id': '106',
    'title': 'Shalat Tahiyatul Masjid',
    'content':
        'Shalat Tahiyatul Masjid adalah shalat sunnah 2 rakaat ketika memasuki masjid sebelum duduk. Hukumnya sunnah, walaupun imam sedang khutbah Jumat (dikerjakan ringan).',
    'category': 'sholat',
    'reference': 'HR. Bukhari no. 444',
  },
  {
    'id': '107',
    'title': 'Shalat Sunnah Wudhu',
    'content':
        'Setelah berwudhu, disunnahkan shalat sunnah 2 rakaat. Keutamaannya: dijamin masuk surga. Shalat ini lebih utama daripada shalat tahiyatul masjid jika keduanya bertabrakan.',
    'category': 'sholat',
    'reference': 'HR. Muslim no. 234',
  },

  // ═══════════════════════════════════════════════════════════════
  //  ADAB ISLAMI (Makan, Tidur, Pakaian, Berbicara, dll)
  // ═══════════════════════════════════════════════════════════════
  {
    'id': '108',
    'title': 'Adab Makan dan Minum',
    'content':
        '1. Mencuci tangan sebelum dan sesudah makan\n2. Membaca basmalah sebelum makan\n3. Makan dan minum dengan tangan kanan\n4. Tidak mencela makanan (jika suka dimakan, jika tidak ditinggalkan)\n5. Tidak berlebihan (israf)\n6. Makan dari tepi piring, bukan tengah\n7. Menjilat jari sebelum cuci tangan\n8. Minum sambil duduk (tidak berdiri)',
    'category': 'adab',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '109',
    'title': 'Adab Tidur',
    'content':
        '1. Berwudhu sebelum tidur\n2. Membaca doa sebelum tidur dan dzikir\n3. Membaca Ayat Kursi, Al-Ikhlas, Al-Falaq, An-Nas\n4. Tidur dengan posisi miring ke kanan\n5. Tidak tidur tengkurap\n6. Membersihkan tempat tidur\n7. Berdoa saat bangun tidur',
    'category': 'adab',
    'reference': 'HR. Bukhari no. 6312',
  },
  {
    'id': '110',
    'title': 'Adab Berpakaian',
    'content':
        '1. Menutup aurat (laki-laki: pusar ke lutut, perempuan: seluruh tubuh kecuali wajah dan telapak tangan)\n2. Pakaian bersih dan sederhana\n3. Mendahulukan kanan saat memakai\n4. Dilarang isbal (pakaian menjulur di bawah mata kaki) karena sombong\n5. Dilarang memakai pakaian sutra dan emas bagi laki-laki\n6. Membaca doa memakai pakaian',
    'category': 'adab',
    'reference': 'HR. Bukhari no. 5783',
  },
  {
    'id': '111',
    'title': 'Adab Masuk dan Keluar Rumah',
    'content':
        '1. Membaca basmalah saat masuk\n2. Mengucapkan salam (Assalamu\'alaikum)\n3. Membaca doa masuk/keluar rumah\n4. Mengucapkan salam meskipun rumah kosong\n5. Memberitahu jika masuk rumah orang lain (minta izin 3x)\n6. Masuk dengan kaki kanan, keluar dengan kaki kiri',
    'category': 'adab',
    'reference': 'QS. An-Nur: 27-28',
  },
  {
    'id': '112',
    'title': 'Adab Bersin dan Menguap',
    'content':
        'Bersin:\n1. Mengucapkan "Alhamdulillah"\n2. Orang lain menjawab "Yarhamukallah"\n3. Orang bersin menjawab "Yahdikumullah wa yushlihu balakum"\nMenguap:\n1. Usahakan ditahan sebisa mungkin\n2. Tutup mulut dengan tangan\n3. Setan tertawa ketika orang menguap',
    'category': 'adab',
    'reference': 'HR. Bukhari no. 6224',
  },
  {
    'id': '113',
    'title': 'Adab Berbicara',
    'content':
        '1. Berkata baik atau diam\n2. Jujur dan menjauhi dusta\n3. Tidak menggunjing (ghibah)\n4. Tidak mengadu domba (namimah)\n5. Tidak mencela/memaki\n6. Tidak berdebat tanpa ilmu\n7. Suara tidak terlalu keras\n8. Mendengarkan saat orang berbicara',
    'category': 'adab',
    'reference': 'HR. Bukhari no. 6015',
  },
  {
    'id': '114',
    'title': 'Adab Bertetangga',
    'content':
        '1. Berbuat baik kepada tetangga\n2. Tidak mengganggu tetangga\n3. Memberi hadiah/sedekah\n4. Menjenguk ketika sakit\n5. Meminjamkan peralatan\n6. Tidak menyakiti dengan bau masakan\n7. Menahan gangguan dari tetangga\nMalaikat Jibril terus berwasiat tentang tetangga sampai Rasulullah mengira tetangga akan mendapat warisan.',
    'category': 'adab',
    'reference': 'HR. Bukhari no. 6015',
  },
  {
    'id': '115',
    'title': 'Adab di Masjid',
    'content':
        '1. Berpakaian rapi dan suci\n2. Masuk dengan kaki kanan, baca doa masuk masjid\n3. Shalat tahiyatul masjid 2 rakaat sebelum duduk\n4. Tidak boleh jual beli di masjid\n5. Tidak boleh mengumumkan barang hilang\n6. Menjaga kebersihan dan ketenangan\n7. Tidak boleh bersuara keras\n8. Keluar dengan kaki kiri, baca doa keluar masjid',
    'category': 'adab',
    'reference': 'HR. Bukhari & Muslim',
  },
  {
    'id': '116',
    'title': 'Adab terhadap Orang Tua',
    'content':
        '1. Berkata dengan sopan dan lembut (tidak mengatakan "ah" atau "uff")\n2. Merendahkan diri di hadapan keduanya\n3. Mendoakan keduanya\n4. Mendahulukan ibu (lebih utama)\n5. Membantu keperluan mereka\n6. Menjaga silaturahmi dengan kerabat orang tua\n7. Ridha Allah ada pada ridha orang tua',
    'category': 'adab',
    'reference': 'QS. Al-Isra: 23-24',
  },
  {
    'id': '117',
    'title': 'Adab Jalanan',
    'content':
        '1. Menundukkan pandangan\n2. Menebarkan salam\n3. Menyuruh yang makruf dan mencegah yang munkar\n4. Membuang gangguan dari jalan\n5. Tidak mengganggu pejalan kaki lain\n6. Berjalan dengan rendah hati',
    'category': 'adab',
    'reference': 'HR. Bukhari no. 2336',
  },

  // ═══════════════════════════════════════════════════════════════
  //  HAID, NIFAS & ISTIHADHAH (Tambahan)
  // ═══════════════════════════════════════════════════════════════
  {
    'id': '118',
    'title': 'Cara Mandi Wajib yang Benar',
    'content':
        '1. Niat mandi wajib\n2. Bersihkan kotoran/benda najis dari tubuh\n3. Berwudhu seperti wudhu shalat\n4. Membasahi rambut 3x (air sampai ke kulit kepala)\n5. Mengguyur tubuh bagian kanan 3x\n6. Mengguyur tubuh bagian kiri 3x\n7. Menggosok seluruh tubuh\n8. Mengalirkan air ke sela-sela jari dan lipatan tubuh',
    'category': 'haid',
    'reference': 'HR. Bukhari no. 248',
  },
  {
    'id': '119',
    'title': 'Perbedaan Haid dan Istihadhah',
    'content':
        'Haid: darah kental, hitam/merah pekat, berbau khas, keluar teratur.\nIstihadhah: darah encer, merah cerah, tidak berbau, keluar terus-menerus atau di luar siklus.\nWanita istihadhah tetap wajib shalat dan puasa seperti biasa.',
    'category': 'haid',
    'reference': 'HR. Bukhari',
  },
  {
    'id': '120',
    'title': 'Larangan Saat Haid',
    'content':
        'Wanita haid dilarang:\n1. Shalat (dan tidak perlu qadha)\n2. Puasa (wajib qadha)\n3. Membaca Al-Quran (menurut jumhur ulama)\n4. Menyentuh mushaf Al-Quran\n5. Thawaf di Ka\'bah\n6. Berhubungan intim\n7. Berdiam diri di masjid (i\'tikaf)\nDiperbolehkan: berdzikir, berdoa, mendengar Al-Quran, bekerja, dan aktivitas normal lainnya.',
    'category': 'haid',
    'reference': 'QS. Al-Baqarah: 222',
  },

  // ═══════════════════════════════════════════════════════════════
  //  JENAZAH (Tambahan)
  // ═══════════════════════════════════════════════════════════════
  {
    'id': '121',
    'title': 'Menutup Aurat Jenazah',
    'content':
        'Setelah jenazah meninggal, wajib segera menutup seluruh tubuhnya dengan kain. Keluarga/ahli waris yang bertanggung jawab mengurus jenazah. Jika tidak ada, pemerintah/kolektif muslim yang wajib.',
    'category': 'jenazah',
    'reference': 'HR. Muslim',
  },
  {
    'id': '122',
    'title': 'Hukum Meratapi Mayat',
    'content':
        'Meratapi mayat dengan suara keras, menampar pipi, menyobek baju, atau mencukur rambut hukumnya haram dan termasuk perbuatan jahiliyah. Menangis dengan diam dan ikhlas diperbolehkan.',
    'category': 'jenazah',
    'reference': 'HR. Bukhari no. 1294',
  },
  {
    'id': '123',
    'title': 'Adab Ziarah Kubur',
    'content':
        '1. Niat mengingat kematian dan mendoakan mayat\n2. Mengucapkan salam: "Assalamu\'alaikum ahlad diyar minal mukminin"\n3. Mendoakan mayat\n4. Tidak duduk di atas kuburan\n5. Tidak menginjak kuburan\n6. Tidak berdoa menghadap kuburan\n7. Tidak mengkultuskan kuburan',
    'category': 'jenazah',
    'reference': 'HR. Muslim no. 975',
  },
  {
    'id': '124',
    'title': 'Keutamaan Mengurus Jenazah',
    'content':
        'Barangsiapa menyaksikan jenazah hingga dishalatkan, baginya pahala 1 qirath. Barangsiapa menyaksikan hingga dimakamkan, baginya 2 qirath. Satu qirath seperti gunung Uhud.',
    'category': 'jenazah',
    'reference': 'HR. Bukhari no. 1325',
  },
];
