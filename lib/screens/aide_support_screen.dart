import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

class AideSupportScreen extends StatelessWidget {
  const AideSupportScreen({super.key});

  static const List<Map<String, String>> _faq = [
    {
      'question': 'Comment accepter une nouvelle livraison ?',
      'reponse': 'Va dans "Nouvelle livraison" depuis l\'Accueil, puis appuie sur "Accepter" sur la commande qui t\'intéresse. Une fois acceptée, elle apparaît dans "En cours".',
    },
    {
      'question': 'Comment confirmer une livraison chez le client ?',
      'reponse': 'Une fois arrivé chez le client, montre-lui le QR Code affiché sur l\'écran de vérification. Le client te communique un PIN à 4 chiffres pour confirmer la livraison.',
    },
    {
      'question': 'Que faire si le client ne répond pas ?',
      'reponse': 'Essaie d\'abord de l\'appeler avec le bouton téléphone sur l\'écran de suivi. Si ça ne marche pas, contacte le support via WhatsApp ci-dessous.',
    },
    {
      'question': 'Quand suis-je payé pour mes livraisons ?',
      'reponse': 'Tes gains sont visibles dans l\'onglet "Gains". Le détail des versements et de la fréquence de paiement te sera communiqué par le support.',
    },
    {
      'question': 'Je ne peux pas activer ma localisation, que faire ?',
      'reponse': 'Vérifie que la localisation est activée dans les réglages de ton téléphone, et que l\'application a bien la permission d\'y accéder. Redémarre l\'app si besoin.',
    },
  ];

  Future<void> _openWhatsApp(BuildContext context) async {
    final url = Uri.parse('https://wa.me/243852849473');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir WhatsApp.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text('Aide & Support', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 17)),
        iconTheme: IconThemeData(color: colors.primary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Questions fréquentes',
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
                  for (int i = 0; i < _faq.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: colors.divider),
                    ExpansionTile(
                      title: Text(
                        _faq[i]['question']!,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.primary),
                      ),
                      iconColor: colors.interface,
                      collapsedIconColor: colors.textGrey,
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _faq[i]['reponse']!,
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
            'Besoin d\'aide supplémentaire ?',
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
                  'Notre équipe est disponible sur WhatsApp pour répondre à tes questions.',
                  style: TextStyle(fontSize: 13, color: colors.textGrey),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openWhatsApp(context),
                    icon: const Icon(Icons.chat, color: Colors.white, size: 18),
                    label: const Text('Contacter sur WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
