import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/dice_provider.dart';
import 'widgets/die_widget.dart';
import 'widgets/app_logo.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => DiceProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kayschima Dice',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const DicePage(),
    );
  }
}

class DicePage extends StatefulWidget {
  const DicePage({super.key});

  @override
  State<DicePage> createState() => _DicePageState();
}

class _DicePageState extends State<DicePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Helles Beige
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(size: 28),
            SizedBox(width: 12),
            Text('Kayschima Dice'),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(255, 255, 255, 0.8),
        elevation: 0,
      ),
      body: Consumer<DiceProvider>(
        builder: (context, provider, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Anzahl der Würfe: ${provider.rollCount}',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .headlineSmall,
                            ),
                            const SizedBox(height: 40),
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              alignment: WrapAlignment.center,
                              children: List.generate(
                                provider.dice.length,
                                    (index) =>
                                    DieWidget(
                                      die: provider.dice[index],
                                      onTap: () =>
                                          provider.toggleDieSelection(index),
                                      showSymbol: provider.rollCount > 0,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_circle_down_outlined,
                                    size: 32,
                                  ),
                                  onPressed:
                                  !provider.isDiceCountChangeable ||
                                      provider.diceCount <= 1
                                      ? null
                                      : () {
                                    provider.setDiceCount(
                                      provider.diceCount - 1,
                                    );
                                  },
                                ),
                                Container(
                                  width: 60,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${provider.diceCount}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_circle_up_outlined,
                                    size: 32,
                                  ),
                                  onPressed:
                                  !provider.isDiceCountChangeable ||
                                      provider.diceCount >= 10
                                      ? null
                                      : () {
                                    provider.setDiceCount(
                                      provider.diceCount + 1,
                                    );
                                  },
                                ),
                              ],
                            ),
                            const Text(
                              'Anzahl Würfel (1-10)',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<DiceProvider>(
        builder: (context, provider, child) {
          return Container(
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed:
                    provider.isRolling ? null : () => provider.reset(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      side: const BorderSide(color: Colors.black),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: provider.isRolling ? null : () =>
                        provider.rollDice(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Würfeln',
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              AlertDialog(
                                title: const Row(
                                  children: [
                                    AppLogo(size: 32),
                                    SizedBox(width: 16),
                                    Text('Kayschima Dice'),
                                  ],
                                ),
                                content: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Eine moderne Würfel-App.\n\n'
                                            'Tippe auf die Würfel nach dem ersten Wurf, um sie zu sperren.\n'
                                            'Ändere die Anzahl der Würfel mit den Pfeiltasten.\n\n'
                                            'Viel Spaß beim Spielen!\n\n'
                                            'https://github.com/kayschima/dice'
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Schließen'),
                                  ),
                                ],
                              ),
                        );
                      }, child: Text(
                    'Info',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
