import json
import os

locales = ['en', 'hi', 'mr']
base_dir = r'C:\Users\sande\OneDrive\Desktop\Solapur_water_app-main\lib\l10n'

for loc in locales:
    with open(os.path.join(base_dir, f'app_{loc}.arb'), 'r', encoding='utf-8') as f:
        data = json.load(f)

    class_name = f'AppLocalizations{loc.capitalize()}'
    out = f"import 'app_localizations.dart';\n\nclass {class_name} extends AppLocalizations {{\n  {class_name}([String locale = '{loc}']) : super(locale);\n\n"

    for k, v in data.items():
        if k.startswith('@'): continue
        val = v.replace("'", "\\'")
        out += f"  @override\n  String get {k} => '{val}';\n\n"

    out += "}\n"

    with open(os.path.join(base_dir, f'app_localizations_{loc}.dart'), 'w', encoding='utf-8') as f:
        f.write(out)
print('Generated localizations!')
