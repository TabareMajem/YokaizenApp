import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/custom_app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 40, left: 30, right: 30, bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(
                title: "Privacy Policy".tr,
                isBackButton: true,
                isColor: false,
                onButtonPressed: () {
                  Navigator.pop(context);
                }
            ),

            const SizedBox(height: 10),
            Text(
              'Yokaizen Privacy Policy'.tr,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Last updated: March 5, 2025'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),

            // Introduction
            Text(
              '1. Introduction'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Yokaizen (hereinafter referred to as "the Company," "we," or "us") is dedicated to protecting your privacy and ensuring the security of your personal information. This Privacy Policy describes how we collect, use, store, and protect information obtained from users of the Yokaizen platform, including our mobile applications and website (collectively, the "Services").'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // Information Collected
            Text(
              '2. Information Collected'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '2.1 Personal Information'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Account Information: We collect your name, email address, age, and other profile information provided during account creation.\n\nHealth Information: We collect information regarding your mental and emotional health through questionnaires, interactions with the AI companion, and platform usage.\n\nDevice Information: We collect information about your device, including device type, operating system, unique device identifiers, IP address, and mobile network information.'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 15),
            Text(
              '2.2 Usage Data'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Interaction Data: Information about how you interact with the Services, such as features used, content viewed, and time spent.\n\nBiometric Data: If you use the Yokaizen Ring, we collect biometric data such as heart rate variability, skin conductance, and other physiological metrics used for emotional state analysis.\n\nCommunication Data: Content from interactions with the AI companion and feedback you provide.'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // How We Use Your Information
            Text(
              '3. How We Use Your Information'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '3.1 Service Delivery'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Creating and maintaining accounts\n\nProviding personalized AI companion experiences\n\nAnalyzing emotional patterns to deliver appropriate support\n\nImproving emotion recognition algorithms and therapeutic content'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 15),
            Text(
              '3.2 Service Improvement'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Enhancing platform functionality and user experience\n\nDeveloping new content and features based on user needs\n\nTroubleshooting technical issues'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 15),
            Text(
              '3.3 Communication'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Sending service announcements and updates\n\nResponding to inquiries and support requests\n\nProviding information on new features (with user consent)'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // How We Protect Your Information
            Text(
              '4. How We Protect Your Information'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '4.1 Security Measures'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Implementing industry-standard encryption for data transmission\n\nStoring data on secure servers with strict access controls\n\nRegular review and updating of security measures\n\nAnonymizing and aggregating sensitive data where possible'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 15),
            Text(
              '4.2 Data Retention'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Retaining personal information only as long as necessary to provide services\n\nAllowing account and associated data deletion requests at any time\n\nAnonymized information may be retained for research and improvement purposes'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // Information Sharing
            Text(
              '5. Information Sharing'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '5.1 Limited Sharing'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'We do not sell your personal information to third parties. Information may be shared in limited circumstances:\n\nService Providers: Trusted third parties assisting with operations, business execution, or service provision, under confidentiality agreements.\n\nLegal Requirements: For legal compliance, enforcing terms of service, protecting our rights, or responding to emergencies.\n\nResearch Partners: Sharing anonymized data with research institutions for advancing mental health science, only with explicit user consent.'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 15),
            Text(
              '5.2 Aggregated or De-identified Data'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'We may share aggregated or de-identified data that cannot reasonably identify you.'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // Your Rights and Choices
            Text(
              '6. Your Rights and Choices'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '6.1 Access and Control'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You have the right to:\n\nAccess your personal information and download copies\n\nCorrect inaccurate information\n\nDelete your account and personal information\n\nLimit or object to certain processing activities\n\nOpt out of promotional communications\n\nTo exercise these rights, email privacy@yokaizen.com with the subject "Privacy Request."'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 15),
            Text(
              '6.2 Account Deletion'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'To delete your account:\n\nEmail support@yokaizen.com with the subject "Account Deletion"\n\nInclude your account email address, phone number, and name\n\nWe will confirm deletion via email\n\nAccount deletion is permanent, and data cannot be recovered.'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // Children's Privacy
            Text(
              '7. Children\'s Privacy'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Our services are not intended for children under 13. For Yokaizen Kids, parental consent is required, and additional protections comply with applicable child privacy laws.'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // International Data Transfers
            Text(
              '8. International Data Transfers'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'If your information is transferred outside of Japan, we ensure compliance with applicable data protection laws and appropriate safeguards for your information.'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // Changes to This Privacy Policy
            Text(
              '9. Changes to This Privacy Policy'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'This Privacy Policy may be periodically updated. Significant changes will be communicated by posting the updated policy on this page and updating the "Last Updated" date.'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // Contact Us
            Text(
              '10. Contact Us'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'For questions regarding this Privacy Policy or our data practices, contact us at:\n\nEmail: privacy@yokaizen.com\nCompany Name: Yokaizen LLC\nHeadquarters: 1-29-3 Higashi, Shibuya-ku, Tokyo\nRepresentative: Majen Olivera Tabare'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 40),
            Text(
              'For more information, please visit our website at https://yokaizen.com'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}