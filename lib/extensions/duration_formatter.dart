// hbttrckr: just a habit tracker
// Copyright (C) 2026  Burak Miraç Bol
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

extension DurationFormatter on int? {
  // 1. Saat döndürür (örneğin 7200 → 2)
  int get hours {
    if (this == null) return 0;
    return this! ~/ 3600;
  }

  // 2. Dakika döndürür (örneğin 7385 → 3) → kalan dakikalar
  int get minutes {
    if (this == null) return 0;
    return (this! % 3600) ~/ 60;
  }

  // 3. Saniye döndürür (örneğin 7385 → 5) → kalan saniyeler
  int get seconds {
    if (this == null) return 0;
    return this! % 60;
  }

  // BONUS: 7385 → "2s 3dk 5sn" şeklinde güzel string (isteğe bağlı)
  String get formattedHMS {
    if (this == null || this == 0) return "0 dk";
    final h = hours;
    final m = minutes;
    final s = seconds;

    if (h > 0) return "${h}s ${m}dk ${s}sn";
    if (m > 0) return "${m}dk ${s}sn";
    return "${s}sn";
  }

  // BONUS 2: Sadece "02:03:05" formatı (progress bar vs. için ideal)
  String get formattedHHmmSS {
    if (this == null || this == 0) return "00:00:00";
    final h = hours.toString().padLeft(2, '0');
    final m = minutes.toString().padLeft(2, '0');
    final s = seconds.toString().padLeft(2, '0');
    return "$h:$m:$s";
  }
}
