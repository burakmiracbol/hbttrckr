import 'package:hbttrckr/classes/strengthgauge.dart';
import 'package:flutter/material.dart';
import 'package:hbttrckr/classes/habit.dart';
import 'package:hbttrckr/views/mainappview.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hbttrckr/views/statsview.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wheel_slider/wheel_slider.dart';

import 'package:hbttrckr/providers/habitprovider.dart';
import 'package:hbttrckr/sheets/habit_notes_editor_sheet.dart';

// TODO ERROR : düzenleme oluyor iki iptal tuşu var

// TODO : habitlerde kategorilendirme yapılacak ve ana ekranda ona göre bakma olacak

// TODO : lottie fire . json çalışmıyor ona bak pubspec.yaml dosyasında assets kısmını açtım bir daha bak o şekil dene

// TODO : time ve count selector tasarım
// TODO : time selctor sheet için time saklama biçimini saniyeye çevirdik bu yüzden dakika ile yapılan çoğu metodu düzeltmek lazım
// TODO : mesela habit içinden erişilebilen ve habit içinde kullanılan bir saat ve dakika ve saniye bölme yaparız işlemleri ona göre düzenleriz

// TODO : calendarda ileri gidince habit değerleri gözukmesin ve geri gidince eski günlerin yapılmış değerleri görüntülene bilsin ve beş gün önceki değerler değiştirilemesin

// TODO : Her habit detail screende kendi calendar istatistikleri ve sıralama istatistikleri olsun current streak best streak total sessions done sessions missed sessions skipped sessions planned hours counted hours missed hours
// TODO : succes rate grafiği done missed skipped calendr istatistikleri haftalık süre sayı veya yaptı yapmadı grafiği ve aylık done missed skipped grafiği

void showTimeSelectorSheet(
  BuildContext context,
  Habit habit,
  DateTime selectedDate,
) {
  // Başlangıç değerleri
  num currentHours = habit.getSecondsProgressForDate(selectedDate).hours;
  num currentMinutes = habit.getSecondsProgressForDate(selectedDate).minutes;
  num currentSeconds = habit.getSecondsProgressForDate(selectedDate).seconds;

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
                        context.read<HabitProvider>().setSecondsForThatDate(
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
                        context.read<HabitProvider>().setSecondsForThatDate(
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
                        context.read<HabitProvider>().setSecondsForThatDate(
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
  final DateTime selectedDate;
  final OnHabitUpdated onHabitUpdated;
  final OnHabitDeleted? onHabitDeleted;

  HabitDetailScreen({
    Key? key,
    required this.habitId,
    required this.selectedDate,
    required this.onHabitUpdated,
    required this.onHabitDeleted,
  }) : super(key: key);

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late final currentHabit = Provider.of<HabitProvider>(
    context,
  ).getHabitById(widget.habitId);
  late final selectedDate = Provider.of<HabitProvider>(context).selectedDate;

  @override
  void initState() {
    super.initState();
  }

  void _showEditDialog() {
    // Use a modal bottom sheet for editing — more robust when other sheets are open
    final nameController = TextEditingController(text: currentHabit.name);
    final descriptionController = TextEditingController(text: currentHabit.description);
    Color selectedColor = currentHabit.color;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx2, setStateSheet) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).dialogBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('İptal'),
                        ),
                        Text(
                          'Alışkanlığı Düzenle',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            final provider = context.read<HabitProvider>();
                            final updatedHabit = provider
                                .getHabitById(widget.habitId)
                                .copyWith(
                                  name: nameController.text.trim().isNotEmpty
                                      ? nameController.text.trim()
                                      : provider.getHabitById(widget.habitId).name,
                                  description: descriptionController.text.trim().isNotEmpty
                                      ? descriptionController.text.trim()
                                      : provider.getHabitById(widget.habitId).description,
                                  color: selectedColor,
                                );

                            provider.updateHabit(updatedHabit);
                            widget.onHabitUpdated.call(updatedHabit);
                            Navigator.pop(ctx);
                          },
                          child: const Text('Kaydet'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'İsim'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Açıklama'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            // open color picker as a dialog over sheet
                            Color temp = selectedColor;
                            await showDialog(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                title: Text('Renk Seç'),
                                content: SingleChildScrollView(
                                  child: ColorPicker(
                                    pickerColor: temp,
                                    onColorChanged: (c) => temp = c,
                                    pickerAreaHeightPercent: 0.8,
                                  ),
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(dCtx), child: Text('İptal')),
                                  TextButton(onPressed: () {
                                    setStateSheet(() => selectedColor = temp);
                                    Navigator.pop(dCtx);
                                  }, child: Text('Seç')),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: selectedColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('Renk seç'),
                      ],
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        final currentHabit = provider.getHabitById(widget.habitId);
        return Scaffold(
          primary: false,
          extendBody: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            actions: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.note_alt_outlined),
                    onPressed: () async {
                      final provider = context.read<HabitProvider>();
                      final current = provider.getHabitById(currentHabit.id);
                      final result = await showModalBottomSheet<String?>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => HabitNotesEditorSheet(
                          initialDeltaJson: current.notesDelta,
                        ),
                      );

                      if (result != null) {
                        final updated = current.copyWith(notesDelta: result);
                        provider.updateHabit(updated);
                        widget.onHabitUpdated.call(updated);
                      }
                    },
                  ),
                  SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.format_list_bulleted_rounded),
                    onPressed: () {
                      showModalBottomSheet(
                        enableDrag: true,
                        useSafeArea: true,
                        isScrollControlled: false,
                        context: context,
                        builder: (sheetContext) => StatefulBuilder(
                          builder: (ctx, setStateSheet) => Padding(
                            padding: EdgeInsets.all(8),
                            child: Center(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Stack(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.cancel_outlined,
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Actions",
                                              style: TextStyle(
                                                fontStyle: Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium
                                                    ?.fontStyle,
                                                fontSize: Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium
                                                    ?.fontSize,
                                                decorationStyle:
                                                    Theme.of(context)
                                                        .textTheme
                                                        .displayMedium
                                                        ?.decorationStyle,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Card(
                                      child: ListTile(
                                        leading: Icon(Icons.double_arrow_rounded),
                                        title: Text("Bu Oturumu Atla"),
                                        subtitle: Text("Bu oturum şu an ${currentHabit.isSkippedOnDate(selectedDate ?? DateTime.now()) ? "atlanmış" : "atlanmamış" }"),
                                        onTap: () {
                                          context.read<HabitProvider>().changeSkipHabit(
                                            currentHabit.id,
                                          );
                                        },
                                      )
                                  ),
                                  Card(
                                      child: ListTile(
                                        leading: Icon(Icons.edit),
                                        title: Text("Bu Alışkanlığı Düzenle"),
                                        subtitle: Text("Mesela renk değiştirmeye ne dersin"),
                                        onTap: () {
                                          // Close the actions bottom sheet first then push edit page
                                          try {
                                            Navigator.pop(sheetContext);
                                          } catch (_) {}
                                          // schedule push after pop
                                          Future.microtask(() {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => EditHabitPage(habitId: currentHabit.id, onSaved: (h) {
                                                  widget.onHabitUpdated.call(h);
                                                }),
                                              ),
                                            );
                                          });
                                        },
                                      )
                                  ),
                                  Card(
                                      child: ListTile(
                                        leading: Icon(Icons.share),
                                        title: Text("Bu Alışkanlığı Paylaş"),
                                        subtitle: Text("Ve ya fotosunu kaydet sana kalmış"),
                                        onTap: () {
                                          SnackBarAction(label: 'valla şu an bunu geliştirmedik', onPressed: () {  },);
                                        },
                                      )
                                  ),
                                  Card(
                                      child: ListTile(
                                        leading: Icon(Icons.delete),
                                        title: Text("Bu alışkanlığı Sil"),
                                        subtitle: Text("silmesen iyi olurdu ama ..."),
                                        onTap: () {
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

                                                    Navigator.of(context).pushAndRemoveUntil(
                                                      MaterialPageRoute(
                                                        builder: (context) => MainAppView(),
                                                      ),
                                                      (route) => false,
                                                    );
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
                                      )
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditHabitPage(habitId: currentHabit.id, onSaved: (h) {
                            widget.onHabitUpdated.call(h);
                          }),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: GlassGlowLayer(
              child: LiquidGlassLayer(
                child: GlassGlow(
                  child: Stack(
                    children: [
                      Positioned(
                        top:
                            MediaQuery.of(context).size.width *
                            -0.5, // üstten ne kadar taşacak (negatif = yukarı taşır)
                        left:
                            MediaQuery.of(context).size.width *
                            -0.2, // soldan taşma
                        right:
                            MediaQuery.of(context).size.width *
                            -0.2, // sağdan taşma
                        child: Container(
                          width: MediaQuery.of(context).size.width * 1.2,
                          height: MediaQuery.of(context).size.width * 1.2,
                          decoration: BoxDecoration(
                            color: currentHabit.color.withValues(alpha: 0.2),
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
                                      backgroundColor: currentHabit.color
                                          .withValues(alpha: 0.3),
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
                                  shape: LiquidRoundedRectangle(
                                    borderRadius: 16,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        left: 8.0,
                                        right: 8.0,
                                      ),
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
                                  shape: LiquidRoundedRectangle(
                                    borderRadius: 4,
                                  ),
                                  child: Container(
                                    margin: EdgeInsets.only(left: 4, right: 4),
                                    child: Text(
                                      currentHabit.description,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GlassGlow(
                                  child: LiquidGlass(
                                    shape: LiquidRoundedRectangle(
                                      borderRadius: 6,
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        left: 8.0,
                                        right: 8.0,
                                      ),
                                      child: Text(
                                        'Toplam (ekle) gün',
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
                                      currentHabit.isSkippedOnDate(
                                            selectedDate ?? DateTime.now(),
                                          )
                                          ? LiquidGlass(
                                              shape: LiquidOval(),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  4.0,
                                                ),
                                                child: IconButton(
                                                  onPressed: () {},
                                                  icon: Icon(Icons.skip_next),
                                                  style: IconButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : LiquidGlass(
                                              shape: LiquidOval(),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  4.0,
                                                ),
                                                child: IconButton(
                                                  onPressed: () => context
                                                      .read<HabitProvider>()
                                                      .toggleTaskCompletion(
                                                        currentHabit.id,
                                                      ),
                                                  icon:
                                                      currentHabit
                                                          .isCompletedOnDate(
                                                            selectedDate ??
                                                                DateTime.now(),
                                                          )
                                                      ? const Icon(
                                                          Icons.done,
                                                          color: Colors.green,
                                                        )
                                                      : const Icon(
                                                          Icons.circle_outlined,
                                                        ),
                                                  style: IconButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            )
                                    // COUNT
                                    else if (currentHabit.type ==
                                        HabitType.count)
                                      currentHabit.isSkippedOnDate(
                                            selectedDate ?? DateTime.now(),
                                          )
                                          ? Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: LiquidGlass(
                                                shape: LiquidRoundedRectangle(
                                                  borderRadius: 16,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    4.0,
                                                  ),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          currentHabit.color
                                                              .withValues(
                                                                alpha: 0.2,
                                                              ),
                                                      shape:
                                                          const StadiumBorder(),
                                                    ),
                                                    onPressed: () {},
                                                    child: Text("Atlandı"),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    4.0,
                                                  ),
                                                  child: LiquidGlass(
                                                    shape:
                                                        LiquidRoundedRectangle(
                                                          borderRadius: 16,
                                                        ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4.0,
                                                          ),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              currentHabit.color
                                                                  .withValues(
                                                                    alpha: 0.2,
                                                                  ),
                                                          shape:
                                                              const StadiumBorder(),
                                                        ),
                                                        onPressed: () {
                                                          context
                                                              .read<
                                                                HabitProvider
                                                              >()
                                                              .incrementCount(
                                                                currentHabit.id,
                                                              );
                                                        },
                                                        child: const Icon(
                                                          Icons.add,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: LiquidGlass(
                                                    shape:
                                                        LiquidRoundedRectangle(
                                                          borderRadius: 16,
                                                        ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4.0,
                                                          ),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              currentHabit.color
                                                                  .withValues(
                                                                    alpha: 0.2,
                                                                  ),
                                                          shape:
                                                              const StadiumBorder(),
                                                        ),
                                                        onPressed: () =>
                                                            showCountSelectorSheet(
                                                              context,
                                                              currentHabit,
                                                              habit:
                                                                  currentHabit,
                                                            ),
                                                        child: Text(
                                                          "${currentHabit.getCountProgressForDate(selectedDate ?? DateTime.now())}",
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    4.0,
                                                  ),
                                                  child: LiquidGlass(
                                                    shape:
                                                        LiquidRoundedRectangle(
                                                          borderRadius: 16,
                                                        ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4.0,
                                                          ),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              currentHabit.color
                                                                  .withValues(
                                                                    alpha: 0.2,
                                                                  ),
                                                          shape:
                                                              const StadiumBorder(),
                                                        ),
                                                        onPressed: () {
                                                          context
                                                              .read<
                                                                HabitProvider
                                                              >()
                                                              .decrementCount(
                                                                currentHabit.id,
                                                              );
                                                        },
                                                        child: const Icon(
                                                          Icons.remove,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                    // TIME
                                    else if (currentHabit.type ==
                                        HabitType.time)
                                      currentHabit.isSkippedOnDate(
                                            selectedDate ?? DateTime.now(),
                                          )
                                          ? Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: LiquidGlass(
                                                shape: LiquidRoundedRectangle(
                                                  borderRadius: 16,
                                                ),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    shape:
                                                        const StadiumBorder(),
                                                  ),
                                                  onPressed: () {},
                                                  child: Text("Atlandı"),
                                                ),
                                              ),
                                            )
                                          : Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: LiquidGlass(
                                                    shape: LiquidOval(),
                                                    child: Consumer<HabitProvider>(
                                                      builder: (context, provider, child) {
                                                        final bool isRunning =
                                                            provider
                                                                .runningTimers[currentHabit
                                                                .id] ??
                                                            false;

                                                        return IconButton(
                                                          style:
                                                              IconButton.styleFrom(
                                                                foregroundColor:
                                                                    Colors.grey,
                                                              ),
                                                          onPressed: () {
                                                            provider.resetTimer(
                                                              currentHabit.id,
                                                            ); // sıfırla
                                                            if (isRunning) {
                                                              provider.toggleTimer(
                                                                currentHabit.id,
                                                              ); // timer'ı da durdur
                                                            }
                                                          },
                                                          icon: const Icon(
                                                            Icons.refresh,
                                                            size: 25,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: LiquidGlass(
                                                    shape:
                                                        LiquidRoundedRectangle(
                                                          borderRadius: 16,
                                                        ),
                                                    child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        shape:
                                                            const StadiumBorder(),
                                                      ),
                                                      onPressed: () =>
                                                          showTimeSelectorSheet(
                                                            context,
                                                            currentHabit,
                                                            selectedDate ??
                                                                DateTime.now(),
                                                          ),
                                                      child: Text(
                                                        currentHabit
                                                            .getSecondsProgressForDate(
                                                              selectedDate ??
                                                                  DateTime.now(),
                                                            )
                                                            .toInt()
                                                            .formattedHMS,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: LiquidGlass(
                                                    shape: LiquidOval(),
                                                    child: Consumer<HabitProvider>(
                                                      builder: (context, provider, child) {
                                                        final bool isRunning =
                                                            provider
                                                                .runningTimers[currentHabit
                                                                .id] ??
                                                            false;

                                                        return IconButton(
                                                          style:
                                                              IconButton.styleFrom(
                                                                foregroundColor:
                                                                    Colors.grey,
                                                              ),
                                                          onPressed: () {
                                                            provider
                                                                .toggleTimer(
                                                                  currentHabit
                                                                      .id,
                                                                );
                                                          },
                                                          icon: Icon(
                                                            isRunning
                                                                ? Icons.pause
                                                                : Icons
                                                                      .play_arrow,
                                                            size: 25,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                    // Diğer tipler
                                    else
                                      const Placeholder(),
                                  ],
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: LiquidGlass(
                                  shape: LiquidRoundedRectangle(
                                    borderRadius: 24,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        StrengthGauge(
                                          strength: currentHabit.strength
                                              .toDouble()
                                              .roundToDouble(), // 0-100 arası int
                                          size: 200,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: LiquidGlass(
                                          shape: LiquidRoundedRectangle(
                                            borderRadius: 16,
                                          ),
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
                                          shape: LiquidRoundedRectangle(
                                            borderRadius: 16,
                                          ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: LiquidGlass(
                                          shape: LiquidRoundedRectangle(
                                            borderRadius: 16,
                                          ),
                                          child: StatCard(
                                            "Alışkanlık Seviyesi",
                                            "${currentHabit.strengthLevel}",
                                            currentHabit.strengthLevel ==
                                                    "Efsane"
                                                ? Icons.hotel_class
                                                : currentHabit.strengthLevel ==
                                                      "Usta"
                                                ? Icons.star
                                                : currentHabit.strengthLevel ==
                                                      "Güçlü"
                                                ? Icons.star_half
                                                : currentHabit.strengthLevel ==
                                                      "Orta"
                                                ? Icons.favorite
                                                : currentHabit.strengthLevel ==
                                                      "Zayıf"
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
                              Container(
                                margin: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: LiquidGlass(
                                  shape: LiquidRoundedRectangle(
                                    borderRadius: 8,
                                  ),
                                  child: TableCalendar(
                                    firstDay: DateTime.utc(2020, 1, 1),
                                    lastDay: DateTime.utc(2030, 12, 31),
                                    focusedDay: DateTime.now(),
                                    calendarFormat: CalendarFormat.month,
                                    startingDayOfWeek: StartingDayOfWeek.monday,
                                    headerStyle: const HeaderStyle(
                                      formatButtonVisible: false,
                                      titleCentered: true,
                                    ),

                                    // Günlerin nasıl renkleneceğini belirle
                                    calendarBuilders: CalendarBuilders(
                                      defaultBuilder:
                                          (context, day, focusedDay) {
                                            // Gelecek günler → siyah / şeffaf
                                            if (day.isAfter(DateTime.now())) {
                                              return Center(
                                                child: Text(
                                                  '${day.day}',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              );
                                            }
                                            return null; // normal gün
                                          },

                                      todayBuilder: (context, day, focusedDay) {
                                        return Center(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.pinkAccent,
                                                width: 2,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${day.day}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },

                                      markerBuilder: (context, day, events) {
                                        if (day.isAfter(DateTime.now()))
                                          return null; // gelecekte marker yok

                                        final normalizedDay = DateTime(
                                          day.year,
                                          day.month,
                                          day.day,
                                        );

                                        bool isDone = false;
                                        bool isSkipped = false;

                                        // Task tipi
                                        if (currentHabit.type ==
                                            HabitType.task) {
                                          isDone = currentHabit
                                              .dailyProgress[normalizedDay];
                                        }
                                        // Count tipi
                                        else if (currentHabit.type ==
                                            HabitType.count) {
                                          final v = currentHabit
                                              .dailyProgress[normalizedDay];
                                          final achieved = (v is num)
                                              ? v.toInt()
                                              : 0;
                                          isDone =
                                              achieved >=
                                              (currentHabit.targetCount ?? 1);
                                          isSkipped = v == "skipped";
                                        }
                                        // Time tipi
                                        else if (currentHabit.type ==
                                            HabitType.time) {
                                          final v = currentHabit
                                              .dailyProgress[normalizedDay];
                                          final achievedSeconds = (v is num)
                                              ? v.toInt()
                                              : 0;
                                          final targetSecs =
                                              currentHabit.targetSeconds ?? 60;
                                          isDone =
                                              achievedSeconds >= targetSecs;
                                          isSkipped = v == "skipped";
                                        }

                                        Color? bgColor;
                                        if (isDone) {
                                          bgColor = Colors.green.withValues(
                                            alpha: 0.8,
                                          );
                                        } else if (isSkipped) {
                                          bgColor = Colors.grey.withValues(
                                            alpha: 0.8,
                                          );
                                        } else if (day.isBefore(
                                          DateTime.now(),
                                        )) {
                                          bgColor = Colors.red.withValues(
                                            alpha: 0.8,
                                          ); // yapılmayan geçmiş gün
                                        }

                                        if (bgColor != null) {
                                          return Center(
                                            child: Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: bgColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${day.day}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }

                                        return null;
                                      },
                                    ),
                                  ),
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

// Full-screen edit page to avoid overlay conflicts with other sheets
class EditHabitPage extends StatefulWidget {
  final String habitId;
  final void Function(Habit) onSaved;
  const EditHabitPage({Key? key, required this.habitId, required this.onSaved}) : super(key: key);

  @override
  State<EditHabitPage> createState() => _EditHabitPageState();
}

class _EditHabitPageState extends State<EditHabitPage> {
  late Habit currentHabit;
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  Color _selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    final prov = context.read<HabitProvider>();
    currentHabit = prov.getHabitById(widget.habitId);
    _nameCtrl = TextEditingController(text: currentHabit.name);
    _descCtrl = TextEditingController(text: currentHabit.description);
    _selectedColor = currentHabit.color;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final prov = context.read<HabitProvider>();
    final updated = currentHabit.copyWith(
      name: _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : currentHabit.name,
      description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : currentHabit.description,
      color: _selectedColor,
    );
    prov.updateHabit(updated);
    widget.onSaved(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alışkanlığı Düzenle'),
        actions: [
          TextButton(onPressed: _save, child: Text('Kaydet', style: TextStyle(color: Colors.white)))
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'İsim')),
            SizedBox(height: 12),
            TextField(controller: _descCtrl, decoration: InputDecoration(labelText: 'Açıklama'), maxLines: 4),
            SizedBox(height: 12),
            Row(children: [
              GestureDetector(
                onTap: () async {
                  Color temp = _selectedColor;
                  await showDialog(context: context, builder: (dCtx) => AlertDialog(
                    title: Text('Renk Seç'),
                    content: SingleChildScrollView(child: ColorPicker(pickerColor: temp, onColorChanged: (c) => temp = c, pickerAreaHeightPercent: 0.8)),
                    actions: [TextButton(onPressed: () => Navigator.pop(dCtx), child: Text('İptal')), TextButton(onPressed: () { setState(() => _selectedColor = temp); Navigator.pop(dCtx); }, child: Text('Seç'))],
                  ));
                },
                child: Container(width:44, height:44, decoration: BoxDecoration(color:_selectedColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24))),
              ),
              SizedBox(width:12), Text('Renk seç')
            ])
          ],
        ),
      ),
    );
  }
}
