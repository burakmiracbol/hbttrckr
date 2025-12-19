

import 'package:flutter/material.dart';
import 'package:hbttrckr/classes/habit.dart'; // senin proje adına göre değiştir
import 'package:hbttrckr/views/mainappview.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hbttrckr/views/statsview.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:provider/provider.dart';
import 'package:wheel_slider/wheel_slider.dart';

import 'package:hbttrckr/providers/habitprovider.dart';

// TODO ERROR : düzenleme oluyor iki iptal tuşu var

// TODO : lottie fire . json çalışmıyor ona bak pubspec.yaml dosyasında assets kısmını açtım bir daha bak o şekil dene

// TODO : time ve count selector tasarım
// TODO : time selctor sheet için time saklama biçimini saniyeye çevirdik bu yüzden dakika ile yapılan çoğu metodu düzeltmek lazım
// TODO : mesela habit içinden erişilebilen ve habit içinde kullanılan bir saat ve dakika ve saniye bölme yaparız işlemleri ona göre düzenleriz

// TODO : calendarda ileri gidince habit değerleri gözükmesin ve geri gidince eski günlerin yapılmış değerleri görüntülene bilsin ve beş gün önceki değerler değiştirilemesin

// TODO : Her habit detail screende kendi calendar istatistikleri ve sıralama istatistikleri olsun current streak best streak total sessions done sessions missed sessions skipped sessions planned hours counted hours missed hours
// TODO : succes rate grafiği done missed skipped calendr istatistikleri haftalık süre sayı veya yaptı yapmadı grafiği ve aylık done missed skipped grafiği 

void showTimeSelectorSheet(BuildContext context, Habit habit) {
  // Başlangıç değerleri
  num currentHours = habit.todaySecondsProgress.hours;
  num currentMinutes = habit.todaySecondsProgress.minutes;
  num currentSeconds = habit.todaySecondsProgress.seconds;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    enableDrag: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setStateSheet) => Container(
        height: 500,
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Üst bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      "İptal",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const Text(
                    "Süre Seç",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      "Tamam",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),

            // WHEEL'LER
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SAAT
                  Expanded(
                    child: WheelSlider.number(
                      horizontal: false,
                      totalCount: 24,
                      initValue: currentHours,
                      currentIndex: currentHours,
                      onValueChanged: (val) {
                        setStateSheet(() {
                          currentHours = val;
                        });
                        final total =
                            (currentHours * 3600) +
                            (currentMinutes * 60) +
                            currentSeconds;
                        context.read<HabitProvider>().setTodaySeconds(
                          habit.id,
                          total.toInt(),
                        );
                      },
                      selectedNumberStyle: const TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                      unSelectedNumberStyle: const TextStyle(
                        fontSize: 24,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  // DAKİKA
                  Expanded(
                    child: WheelSlider.number(
                      horizontal: false,
                      totalCount: 60,
                      initValue: currentMinutes,
                      currentIndex: currentMinutes,
                      onValueChanged: (val) {
                        setStateSheet(() {
                          currentMinutes = val;
                          // diğerleri için de minutes = val.toInt(); seconds = val.toInt();
                        });

                        // Tamam butonuna gerek yok, anında kaydet
                        final total =
                            (currentHours * 3600) +
                            (currentMinutes * 60) +
                            currentSeconds;
                        context.read<HabitProvider>().setTodaySeconds(
                          habit.id,
                          total.toInt(),
                        );
                      },
                    ),
                  ),
                  // SANİYE
                  Expanded(
                    child: WheelSlider.number(
                      horizontal: false,
                      totalCount: 60,
                      initValue: currentSeconds,
                      currentIndex: currentSeconds,
                      onValueChanged: (val) {
                        setStateSheet(() {
                          currentSeconds = val;
                          // diğerleri için de minutes = val.toInt(); seconds = val.toInt();
                        });

                        // Tamam butonuna gerek yok, anında kaydet
                        final total =
                            (currentHours * 3600) +
                            (currentMinutes * 60) +
                            currentSeconds;
                        context.read<HabitProvider>().setTodaySeconds(
                          habit.id,
                          total.toInt(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Toplam göster (isteğe bağlı)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "${currentHours.toInt().toString().padLeft(2, '0')}:${currentMinutes.toInt().toString().padLeft(2, '0')}:${currentSeconds.toInt().toString().padLeft(2, '0')}",
                style: const TextStyle(color: Colors.white70, fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// void showTimeSelectorSheet(
//   BuildContext context,
//   Habit currentHabit, {
//   required Function(int minutes) onSelected,
//   required Habit habit,
// }) {
//   final initialSeconds = habit.todaySecondsProgress; // senin getter’ın
//   int hours = initialSeconds.hours;
//   int minutes = initialSeconds.minutes;
//   int seconds = initialSeconds.seconds;
//   num? nCurrentValue1;
//   num? nCurrentValue2;
//   num? nCurrentValue3;
//   showModalBottomSheet(
//     useSafeArea: true,
//     enableDrag: false,
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (ctx) => Material(
//       child: Container(
//         height: 400,
//         decoration: const BoxDecoration(
//           color: Colors.black87,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: StatefulBuilder(
//           builder: (ctx, setStateSheet) => Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(ctx);
//                     },
//                     child: const Icon(Icons.cancel_outlined),
//                   ),
//                   Text(
//                     "Dakika Seç",
//                     style: TextStyle(color: Colors.white, fontSize: 18),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(ctx);
//                     },
//                     child: Icon(Icons.done),
//                   ),
//                 ],
//               ),
//             ),
//             // BURAYA SEN TASARIM YAPACAKSIN
//             Expanded(
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       //
//                       WheelSlider.number(
//                         horizontal: false,
//                         isInfinite: false,
//                         pointerColor: Colors.white,
//                         showPointer: false,
//                         perspective: 0.01,
//                         verticalListHeight: double.infinity,
//                         totalCount: 24,
//                         initValue: hours,
//                         selectedNumberStyle: TextStyle(
//                           fontSize: 13.0,
//                           color: Colors.white,
//                         ),
//                         unSelectedNumberStyle: TextStyle(
//                           fontSize: 12.0,
//                           color: Colors.white.withValues(alpha: 200),
//                         ),
//                         currentIndex: nCurrentValue1,
//                         onValueChanged: (val) {
//                           Provider.of<HabitProvider>(
//                             context,
//                             listen: false,
//                           ).addTimeById(habit.id, hours: val);
//                         },
//                         hapticFeedbackType: HapticFeedbackType.heavyImpact,
//                       ),
//                       //
//                       WheelSlider.number(
//                         horizontal: false,
//                         isInfinite: false,
//                         pointerColor: Colors.white,
//                         showPointer: false,
//                         perspective: 0.01,
//                         verticalListHeight: double.infinity,
//                         totalCount: 59,
//                         initValue: minutes,
//                         selectedNumberStyle: TextStyle(
//                           fontSize: 13.0,
//                           color: Colors.white,
//                         ),
//                         unSelectedNumberStyle: TextStyle(
//                           fontSize: 12.0,
//                           color: Colors.white.withValues(alpha: 200),
//                         ),
//                         currentIndex: nCurrentValue2,
//                         onValueChanged: (val) {
//                           Provider.of<HabitProvider>(
//                             context,
//                             listen: false,
//                           ).addTimeById(habit.id, minutes : val);
//                         },
//                         hapticFeedbackType: HapticFeedbackType.heavyImpact,
//                       ),
//                       //
//                       WheelSlider.number(
//                         horizontal: false,
//                         isInfinite: false,
//                         pointerColor: Colors.white,
//                         showPointer: false,
//                         perspective: 0.01,
//                         verticalListHeight: double.infinity,
//                         totalCount: 59,
//                         initValue: seconds,
//                         selectedNumberStyle: TextStyle(
//                           fontSize: 13.0,
//                           color: Colors.white,
//                         ),
//                         unSelectedNumberStyle: TextStyle(
//                           fontSize: 12.0,
//                           color: Colors.white.withValues(alpha: 200),
//                         ),
//                         currentIndex: nCurrentValue3,
//                         onValueChanged: (val) {
//                           Provider.of<HabitProvider>(
//                             context,
//                             listen: false,
//                           ).addTimeById(habit.id, seconds: val);
//                         },
//                         hapticFeedbackType: HapticFeedbackType.heavyImpact,
//                       ),
//
//                     ],
//                   ),
//                 ],
//               ),
//             ), // boş alan
//             const SizedBox(height: 20),
//           ],
//          ),
//         ),
//       ),
//     ),
//   );
// }

void showCountSelectorSheet(
  BuildContext context,
  Habit currentHabit, {
  required Habit habit,
}) {
  num? nCurrentValue;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      height: 400,
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: const Icon(Icons.cancel_outlined),
                ),
                Text(
                  "Sayı Seç",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                ElevatedButton(
                  onPressed: () {
                    // örnek değer, sen değiştireceksin
                    Navigator.pop(ctx);
                  },
                  child: Icon(Icons.done),
                ),
              ],
            ),
          ),
          // BURAYA SEN TASARIM YAPACAKSIN
          Expanded(
            child: WheelSlider.number(
              horizontal: false,
              isInfinite: false,
              pointerColor: Colors.white,
              showPointer: false,
              perspective: 0.01,
              verticalListHeight: double.infinity,
              totalCount: habit.maxCount == null
                  ? 999
                  : habit.maxCount!.toInt(),
              initValue: habit.achievedCount,
              selectedNumberStyle: TextStyle(
                fontSize: 13.0,
                color: Colors.white,
              ),
              unSelectedNumberStyle: TextStyle(
                fontSize: 12.0,
                color: Colors.white.withValues(alpha: 200),
              ),
              currentIndex: nCurrentValue,
              onValueChanged: (val) {
                Provider.of<HabitProvider>(
                  context,
                  listen: false,
                ).changeCount(habit.id, val);
              },
              hapticFeedbackType: HapticFeedbackType.heavyImpact,
            ),
          ), // boş alan
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

// TODO: Appbar veya calendar gibi bir widget ın rengini tüm habitlerin renginin karışımım belirlesin #özellik

class HabitDetailScreen extends StatefulWidget {
  final String habitId;
  final OnHabitUpdated onHabitUpdated;
  final OnHabitDeleted? onHabitDeleted;

   HabitDetailScreen({
    Key? key,
    required this.habitId,
    required this.onHabitUpdated,
    required this.onHabitDeleted,
  }) : super(key: key);

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late final currentHabit = Provider.of<HabitProvider>(context).getHabitById(widget.habitId);

  @override
  void initState() {
    super.initState();
  }

  void _showEditDialog() {
    final nameController = TextEditingController(text: currentHabit.name);
    final descriptionController = TextEditingController(
      text: currentHabit.description,
    );
    Color selectedColor = currentHabit.color;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Alışkanlığı Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'İsim'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Açıklama'),
            ),
            SizedBox(height: 10),
            // Renk seçici
            Text('Renk seç', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) {
                        Color tempColor = currentHabit.color;
                        return AlertDialog(
                          title: Text('Renk Seç'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: tempColor,
                              onColorChanged: (color) {
                                tempColor = color;
                              },
                              pickerAreaHeightPercent: 0.8,
                            ),
                          ),
                          actions: [
                            TextButton(
                              child:  const Text('İptal'),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                            TextButton(
                              child: const Text('Seç'),
                              onPressed: () {
                                setState(() {
                                  selectedColor = tempColor;
                                });
                                Navigator.pop(ctx);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: currentHabit.color,
                      shape: BoxShape.rectangle,
                      border: Border.all(color: Colors.black, width: 3),
                    ),
                    child: Icon(Icons.color_lens, color: Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Seçilen renk', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 24),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('İptal')),
          TextButton(
            onPressed: () {
              // 1. Provider’dan güncel habit’i al
              final provider = context.read<HabitProvider>();
              final updatedHabit = provider
                  .getHabitById(widget.habitId)!
                  .copyWith(
                    name: nameController.text.trim().isNotEmpty
                        ? nameController.text.trim()
                        : provider.getHabitById(widget.habitId)!.name,
                    description: descriptionController.text.trim().isNotEmpty
                        ? descriptionController.text.trim()
                        : provider.getHabitById(widget.habitId)!.description,
                    color: selectedColor,
                  );

              // 2. Provider üzerinden güncelle (tek doğru yol!)
              provider.updateHabit(updatedHabit);

              // 3. Callback’i çağır (eğer hâlâ lazımsa)
              widget.onHabitUpdated.call(updatedHabit);

              Navigator.pop(context);
            },
            child: const Text('İptal'), // veya 'Kaydet'
          ),
        ],
      ),
    );
  }

  void habittoggleToday() {
    setState(() {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      if (currentHabit.isCompletedToday()) {
        currentHabit.completedDates.removeWhere(
          (date) =>
              date.year == todayDate.year &&
              date.month == todayDate.month &&
              date.day == todayDate.day,
        );
      } else {
        currentHabit.completedDates.add(todayDate);
      }
    });

    // ANA EKRANA GÜNCELLENMİŞ HALİNİ GÖNDER
    widget.onHabitUpdated(currentHabit);
  }

  @override
  Widget build(BuildContext context) {
    final bool todayDone = currentHabit.isCompletedToday();

    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        final currentHabit = provider.getHabitById(widget.habitId);


        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            title: Center(child: Text(currentHabit.name)),
            elevation: Theme.of(context).appBarTheme.elevation,
            actions: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showEditDialog();
                    },
                  ),
                  SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Silme onayı al
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Alışkanlığı Sil'),
                          content: Text(
                            '"${currentHabit.name}" alışkanlığını silmek istediğine emin misin?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text('İptal'),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<HabitProvider>().deleteHabit(
                                  currentHabit.id,
                                );
                                Navigator.pop(ctx); // dialogu kapat
                                Navigator.pop(context); // ekrandan çık
                              },
                              child: Text(
                                'Sil',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              )

            ],
          ),
          body: SingleChildScrollView(
            child: GlassGlowLayer(
              child: LiquidGlassLayer(
                child: GlassGlow(
                  child: Stack(
                    children: [
                      Positioned(
                        top: MediaQuery.of(context).size.width * -0.5, // üstten ne kadar taşacak (negatif = yukarı taşır)
                        left: MediaQuery.of(context).size.width * -0.2, // soldan taşma
                        right: MediaQuery.of(context).size.width * -0.2, // sağdan taşma
                        child: Container(
                          width: MediaQuery.of(context).size.width * 1.2,
                          height: MediaQuery.of(context).size.width * 1.2,
                          decoration: BoxDecoration(
                            color: currentHabit.color.withValues(alpha:0.2),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: LiquidGlass(
                                  shape: LiquidOval(),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundColor: currentHabit.color.withValues(
                                        alpha: 0.3,
                                      ),
                                      child: Icon(
                                        Icons.flag,
                                        size: 60,
                                        color: currentHabit.color,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: LiquidGlass(
                                  shape : LiquidRoundedRectangle(borderRadius: 16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      margin: EdgeInsets.only(left: 8.0 , right: 8.0),
                                      child: Text(
                                        currentHabit.name,
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: LiquidGlass(
                                  shape: LiquidRoundedRectangle(borderRadius: 4),
                                  child: Container(
                                    margin: EdgeInsets.only(left: 4,right: 4),
                                    child: Text(
                                      currentHabit.description,
                                      style: TextStyle(fontSize: 18, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GlassGlow(
                                  child: LiquidGlass(
                                    shape: LiquidRoundedRectangle(borderRadius: 6),
                                    child: Container(
                                      margin: EdgeInsets.only(left: 8.0 , right: 8.0),
                                      child: Text(
                                        'Toplam ${currentHabit.totalDays} gün',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // TASK
                                    if (currentHabit.type == HabitType.task)
                                      LiquidGlass(
                                        shape: LiquidOval(),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: IconButton(
                                            onPressed: () => context
                                                .read<HabitProvider>()
                                                .toggleTaskCompletion(currentHabit.id),
                                            icon: currentHabit.isCompletedToday()
                                                ? const Icon(Icons.done, color: Colors.green)
                                                : const Icon(Icons.circle_outlined),
                                            style: IconButton.styleFrom(
                                              padding: const EdgeInsets.all(10),
                                            ),
                                          ),
                                        ),
                                      )
                                    // COUNT
                                    else if (currentHabit.type == HabitType.count)
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: LiquidGlass(
                                              shape: LiquidRoundedRectangle(borderRadius: 16 ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(4.0),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: currentHabit.color
                                                        .withValues(alpha: 0.2),
                                                    shape: const StadiumBorder(),
                                                  ),
                                                  onPressed: () {
                                                    context.read<HabitProvider>().incrementCount(
                                                      currentHabit.id,
                                                    );
                                                  },
                                                  child: const Icon(Icons.add),
                                                ),
                                              ),
                                            ),
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: LiquidGlass(
                                              shape: LiquidRoundedRectangle(borderRadius: 16),
                                              child: Padding(
                                                padding: const EdgeInsets.all(4.0),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: currentHabit.color
                                                        .withValues(alpha: 0.2),
                                                    shape: const StadiumBorder(),
                                                  ),
                                                  onPressed: () => showCountSelectorSheet(
                                                    context,
                                                    currentHabit,
                                                    habit: currentHabit,
                                                  ),
                                                  child: Text(
                                                    "${currentHabit.todayCountProgress}",
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: LiquidGlass(
                                              shape: LiquidRoundedRectangle(borderRadius: 16),
                                              child: Padding(
                                                padding: const EdgeInsets.all(4.0),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: currentHabit.color
                                                        .withValues(alpha: 0.2),
                                                    shape: const StadiumBorder(),
                                                  ),
                                                  onPressed: () {
                                                    context.read<HabitProvider>().decrementCount(
                                                      currentHabit.id,
                                                    );
                                                  },
                                                  child: const Icon(Icons.remove),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    // TIME
                                    else if (currentHabit.type == HabitType.time)
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: LiquidGlass(
                                          shape: LiquidRoundedRectangle(borderRadius: 16),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: currentHabit.color.withValues(
                                                alpha: 0.2,
                                              ),
                                              shape: const StadiumBorder(),
                                            ),
                                            onPressed: () =>
                                                showTimeSelectorSheet(context, currentHabit),
                                            child: Text(
                                              currentHabit.todayMinutesProgress
                                                  .toInt()
                                                  .formattedHMS,
                                            ),
                                          ),
                                        ),
                                      )
                                    // Diğer tipler
                                    else
                                      const Placeholder(),
                                  ],
                                ),
                              ),
                        
                              SizedBox(height: 40),
                              Text('Son 21 gün', style: TextStyle(fontSize: 18)),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: LiquidGlass(
                                  shape: LiquidRoundedRectangle(borderRadius: 16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Wrap(
                                      spacing: 8,
                                      children: List.generate(21, (index) {
                                        final date = DateTime.now().subtract(
                                          Duration(days: 20 - index),
                                        );
                                        final done = currentHabit.completedDates.any(
                                          (d) =>
                                              d.year == date.year &&
                                              d.month == date.month &&
                                              d.day == date.day,
                                        );
                                        return Container(
                                          width: 30,
                                          height: 30,
                                          decoration: ShapeDecoration(
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(color: Colors.grey),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            color: done
                                                ? currentHabit.color
                                                : Colors.black12.withValues(alpha: 0.1),
                                          ),
                                          child: done
                                              ? Icon(Icons.check, size: 20, color: Colors.white)
                                              : null,
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: LiquidGlass(
                                          shape: LiquidRoundedRectangle(borderRadius: 16),
                                          child: StatCard(
                                            "Aktif Streak",
                                            "${currentHabit.currentStreak}",
                                            Icons.whatshot,
                                            Colors.orange,
                                            16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: LiquidGlass(
                                          shape: LiquidRoundedRectangle(borderRadius: 16),
                                          child: StatCard(
                                            "Güç Seviyesi",
                                            "%${currentHabit.strength}",
                                            Icons.trending_up,
                                            Colors.green,
                                            16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: LiquidGlass(
                                          shape: LiquidRoundedRectangle(borderRadius: 16),
                                          child: StatCard(
                                            "Alışkanlık Seviyesi",
                                            "${currentHabit.strengthLevel}",
                                            currentHabit.strengthLevel == "Efsane"
                                                ? Icons.hotel_class
                                                : currentHabit.strengthLevel == "Usta"
                                                ? Icons.star
                                                : currentHabit.strengthLevel == "Güçlü"
                                                ? Icons.star_half
                                                : currentHabit.strengthLevel == "Orta"
                                                ? Icons.favorite
                                                : currentHabit.strengthLevel == "Zayıf"
                                                ? Icons.all_out
                                                : Icons.question_mark,
                                            Colors.blue,
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
