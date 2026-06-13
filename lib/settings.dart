import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'habits.dart';
import 'l10n.dart';
import 'theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = EmberPalette.of(context);

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(L10n.t('settings'),
              style:
                  TextStyle(fontWeight: FontWeight.w700, color: p.ink)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Card(p: p, children: [
              ListTile(
                leading: Icon(Icons.language, color: p.accentDeep),
                title: Text(L10n.t('language'),
                    style: TextStyle(color: p.ink)),
                subtitle: Text(
                  store.langCode.isEmpty
                      ? L10n.t('systemDefault')
                      : (L10n.nativeNames[store.langCode] ?? store.langCode),
                  style: TextStyle(color: p.muted),
                ),
                onTap: () => _pickLanguage(context, p),
              ),
              ListTile(
                leading: Icon(Icons.brightness_6, color: p.accentDeep),
                title:
                    Text(L10n.t('theme'), style: TextStyle(color: p.ink)),
                subtitle: Text(
                  switch (store.themeMode) {
                    ThemeMode.system => L10n.t('themeSystem'),
                    ThemeMode.light => L10n.t('themeLight'),
                    ThemeMode.dark => L10n.t('themeDark'),
                  },
                  style: TextStyle(color: p.muted),
                ),
                onTap: store.cycleTheme,
              ),
            ]),
            const SizedBox(height: 14),
            _Card(p: p, children: [
              ListTile(
                leading: Icon(Icons.copy, color: p.accentDeep),
                title: Text(L10n.t('exportBtn'),
                    style: TextStyle(color: p.ink)),
                onTap: () async {
                  await Clipboard.setData(
                      ClipboardData(text: store.exportData()));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(L10n.t('exportCopied'))));
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.download, color: p.accentDeep),
                title: Text(L10n.t('importBtn'),
                    style: TextStyle(color: p.ink)),
                onTap: () => _importDialog(context, p),
              ),
              ListTile(
                leading: Icon(Icons.privacy_tip_outlined,
                    color: p.accentDeep),
                title: Text(L10n.t('privacy'),
                    style: TextStyle(color: p.ink)),
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: p.card,
                    title: Text(L10n.t('privacy'),
                        style: TextStyle(color: p.ink, fontSize: 18)),
                    content: SelectableText(
                      'https://shakthi666.github.io/ember-habits/',
                      style: TextStyle(color: p.accentDeep),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text('OK',
                            style: TextStyle(color: p.accentDeep)),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            if (store.archivedHabits.isNotEmpty)
              _Card(p: p, children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(L10n.t('archived'),
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: p.muted)),
                ),
                for (final h in store.archivedHabits)
                  ListTile(
                    leading: Icon(h.icon, color: p.muted),
                    title: Text(h.name, style: TextStyle(color: p.ink)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => store.setArchived(h, false),
                          child: Text(L10n.t('unarchive'),
                              style: TextStyle(color: p.accentDeep)),
                        ),
                        IconButton(
                          tooltip: L10n.t('delete'),
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red, size: 20),
                          onPressed: () => store.remove(h),
                        ),
                      ],
                    ),
                  ),
              ]),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Ember 1.1 · ${L10n.t('about')}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: p.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickLanguage(BuildContext context, EmberPalette p) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.card,
        title: Text(L10n.t('language'), style: TextStyle(color: p.ink)),
        content: SizedBox(
          width: double.maxFinite,
          height: 420,
          child: ListView(
            children: [
              RadioListTile<String>(
                value: '',
                groupValue: store.langCode,
                title: Text(L10n.t('systemDefault'),
                    style: TextStyle(color: p.ink)),
                onChanged: (v) {
                  store.setLang('');
                  Navigator.of(ctx).pop();
                },
              ),
              for (final code in L10n.available)
                RadioListTile<String>(
                  value: code,
                  groupValue: store.langCode,
                  title: Text(L10n.nativeNames[code] ?? code,
                      style: TextStyle(color: p.ink)),
                  onChanged: (v) {
                    store.setLang(code);
                    Navigator.of(ctx).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _importDialog(BuildContext context, EmberPalette p) {
    final c = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.card,
        title: Text(L10n.t('importBtn'), style: TextStyle(color: p.ink)),
        content: TextField(
          controller: c,
          maxLines: 4,
          style: TextStyle(color: p.ink, fontSize: 12),
          decoration: InputDecoration(
            hintText: L10n.t('importHint'),
            hintStyle: TextStyle(color: p.muted),
            filled: true,
            fillColor: p.bg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child:
                Text(L10n.t('cancel'), style: TextStyle(color: p.muted)),
          ),
          TextButton(
            onPressed: () {
              final ok = store.importData(c.text);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      ok ? L10n.t('importOk') : L10n.t('importBad'))));
            },
            child: Text('OK', style: TextStyle(color: p.accentDeep)),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final EmberPalette p;
  final List<Widget> children;
  const _Card({required this.p, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(color: p.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}
