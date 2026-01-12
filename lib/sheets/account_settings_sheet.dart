import 'package:flutter/material.dart';

void showAccountSettingsSheet (
    BuildContext context,
    TextEditingController accountController,
    TextEditingController passwordController,
    ) {
  showModalBottomSheet(
    enableDrag: true,
    useSafeArea: true,
    isScrollControlled: true,
    context: context,
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.only(
          top: 16,
          left: 8,
          right: 8,
          bottom: 8,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Align(
                    alignment:
                    Alignment.topLeft,
                    child: Padding(
                      padding:
                      const EdgeInsets.all(
                        4.0,
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(
                            sheetContext,
                          );
                        },
                        icon: Icon(
                          Icons.close,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Account",
                      style: TextStyle(
                        fontSize:
                        Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.fontSize,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(
                  4.0,
                ),
                child: Card(
                  child: TextField(
                    controller:
                    accountController,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText:
                      'Account name',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),
                      ),
                      filled: true,
                      fillColor:
                      Colors.grey[900],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(
                  4.0,
                ),
                child: Card(
                  child: TextField(
                    controller:
                    passwordController,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText:
                      'Password (that is secret don\'t share it)',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),
                      ),
                      filled: true,
                      fillColor:
                      Colors.grey[900],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(
                  4.0,
                ),
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Forgot your password ?\n(okay that is normal but we are tired)",
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(
                  4.0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      Color.fromARGB(
                        255,
                        140,
                        140,
                        73,
                      ),
                    ),
                    onPressed: () {},
                    child: Text("Log in"),
                  ),
                ),
              ),

              Stack(
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.only(
                      top: 6.0,
                    ),
                    child: Center(
                      child: Divider(),
                    ),
                  ),
                  Center(
                    child: Card(
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: Text("  or  "),
                      ),
                    ),
                  ),
                ],
              ),

              Card(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Create Account",
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}