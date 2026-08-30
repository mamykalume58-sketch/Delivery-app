import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';

class AideSupportScreen extends StatelessWidget {
  const AideSupportScreen({super.key});

  List<Map<String, String>> _faq(AppLocalizations l10n) => [
        {'question': l10n.aideSupportScreen_faq1Q, 'reponse': l10n.aideSupportScreen_faq1A},
        {'question': l10n.aideSupportScreen_faq2Q, 'reponse': l10n.aideSupportScreen_faq2A},
        {'question': l10n.aideSupportScreen_faq3Q, 'reponse': l10n.aideSupportScreen_faq3A},
        {'question': l10n.aideSupportScreen_faq4Q, 'reponse': l10n.aideSupportScreen_faq4A},
        {'question': l10n.aideSupportScreen_faq5Q, 'reponse': l10n.aideSupportScreen_faq5A},
      ];

  Future<void> _openWhatsApp(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final url = Uri.parse('https://wa.me/243852849473');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.aideSupportScreen_cantOpenWhatsApp)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final faq = _faq(l10n);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(l10n.aideSupportScreen_title, style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 17)),
        iconTheme: IconThemeData(color: colors.primary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.aideSupportScreen_faqTitle,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.primary),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.divider),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: Column(
                children: [
                  for (int i = 0; i < faq.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: colors.divider),
                    ExpansionTile(
                      title: Text(
                        faq[i]['question']!,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.primary),
                      ),
                      iconColor: colors.interface,
                      collapsedIconColor: colors.textGrey,
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            faq[i]['reponse']!,
                            style: TextStyle(fontSize: 13, color: colors.textGrey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.aideSupportScreen_needMoreHelp,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.primary),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aideSupportScreen_teamAvailable,
                  style: TextStyle(fontSize: 13, color: colors.textGrey),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openWhatsApp(context),
                    icon: const Icon(Icons.chat, color: Colors.white, size: 18),
                    label: Text(l10n.aideSupportScreen_contactWhatsApp, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.success,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
