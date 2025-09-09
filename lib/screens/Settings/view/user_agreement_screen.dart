import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/custom_app_bar.dart';

class UserAgreementsScreen extends StatelessWidget {
  const UserAgreementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
      padding: const EdgeInsets.only(top: 40, left: 30, right: 30, bottom: 30),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(
              title: "User Agreements".tr,
              isBackButton: true,
              isColor: false,
              onButtonPressed: () {
                Navigator.pop(context);
              }
            ),

            const SizedBox(height: 10),
            Text(
              'LICENSED APPLICATION END USER LICENSE AGREEMENT'.tr,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Apps made available through the App Store are licensed, not sold, to you. Your license to each App is subject to your prior acceptance of either this Licensed Application End User License Agreement ("Standard EULA"), or a custom end user license agreement between you and the Application Provider ("Custom EULA"), if one is provided. Your license to any Apple App under this Standard EULA or Custom EULA is granted by Apple, and your license to any Third Party App under this Standard EULA or Custom EULA is granted by the Application Provider of that Third Party App. Any App that is subject to this Standard EULA is referred to herein as the "Licensed Application." The Application Provider or Apple as applicable ("Licensor") reserves all rights in and to the Licensed Application not expressly granted to you under this Standard EULA.'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'a. Scope of License:'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Licensor grants to you a nontransferable license to use the Licensed Application on any Apple-branded products that you own or control and as permitted by the Usage Rules. The terms of this Standard EULA will govern any content, materials, or services accessible from or purchased within the Licensed Application as well as upgrades provided by Licensor that replace or supplement the original Licensed Application, unless such upgrade is accompanied by a Custom EULA. Except as provided in the Usage Rules, you may not distribute or make the Licensed Application available over a network where it could be used by multiple devices at the same time. You may not transfer, redistribute or sublicense the Licensed Application and, if you sell your Apple Device to a third party, you must remove the Licensed Application from the Apple Device before doing so. You may not copy (except as permitted by this license and the Usage Rules), reverse-engineer, disassemble, attempt to derive the source code of, modify, or create derivative works of the Licensed Application, any updates, or any part thereof (except as and only to the extent that any foregoing restriction is prohibited by applicable law or to the extent as may be permitted by the licensing terms governing use of any open-sourced components included with the Licensed Application).'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'b. Consent to Use of Data:'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You agree that Licensor may collect and use technical data and related information—including but not limited to technical information about your device, system and application software, and peripherals—that is gathered periodically to facilitate the provision of software updates, product support, and other services to you (if any) related to the Licensed Application. Licensor may use this information, as long as it is in a form that does not personally identify you, to improve its products or to provide services or technologies to you.'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'c. Termination:'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'This Standard EULA is effective until terminated by you or Licensor. Your rights under this Standard EULA will terminate automatically if you fail to comply with any of its terms.'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'd. External Services:'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'The Licensed Application may enable access to Licensor\'s and/or third-party services and websites (collectively and individually, "External Services"). You agree to use the External Services at your sole risk. Licensor is not responsible for examining or evaluating the content or accuracy of any third-party External Services, and shall not be liable for any such third-party External Services. Data displayed by any Licensed Application or External Service, including but not limited to financial, medical and location information, is for general informational purposes only and is not guaranteed by Licensor or its agents. You will not use the External Services in any manner that is inconsistent with the terms of this Standard EULA or that infringes the intellectual property rights of Licensor or any third party. You agree not to use the External Services to harass, abuse, stalk, threaten or defame any person or entity, and that Licensor is not responsible for any such use. External Services may not be available in all languages or in your Home Country, and may not be appropriate or available for use in any particular location. To the extent you choose to use such External Services, you are solely responsible for compliance with any applicable laws. Licensor reserves the right to change, suspend, remove, disable or impose access restrictions or limits on any External Services at any time without notice or liability to you.'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'e. NO WARRANTY:'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'YOU EXPRESSLY ACKNOWLEDGE AND AGREE THAT USE OF THE LICENSED APPLICATION IS AT YOUR SOLE RISK. TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THE LICENSED APPLICATION AND ANY SERVICES PERFORMED OR PROVIDED BY THE LICENSED APPLICATION ARE PROVIDED "AS IS" AND "AS AVAILABLE," WITH ALL FAULTS AND WITHOUT WARRANTY OF ANY KIND, AND LICENSOR HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS WITH RESPECT TO THE LICENSED APPLICATION AND ANY SERVICES, EITHER EXPRESS, IMPLIED, OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES AND/OR CONDITIONS OF MERCHANTABILITY, OF SATISFACTORY QUALITY, OF FITNESS FOR A PARTICULAR PURPOSE, OF ACCURACY, OF QUIET ENJOYMENT, AND OF NONINFRINGEMENT OF THIRD-PARTY RIGHTS. NO ORAL OR WRITTEN INFORMATION OR ADVICE GIVEN BY LICENSOR OR ITS AUTHORIZED REPRESENTATIVE SHALL CREATE A WARRANTY. SHOULD THE LICENSED APPLICATION OR SERVICES PROVE DEFECTIVE, YOU ASSUME THE ENTIRE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION. SOME JURISDICTIONS DO NOT ALLOW THE EXCLUSION OF IMPLIED WARRANTIES OR LIMITATIONS ON APPLICABLE STATUTORY RIGHTS OF A CONSUMER, SO THE ABOVE EXCLUSION AND LIMITATIONS MAY NOT APPLY TO YOU.'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'f. Limitation of Liability:'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'TO THE EXTENT NOT PROHIBITED BY LAW, IN NO EVENT SHALL LICENSOR BE LIABLE FOR PERSONAL INJURY OR ANY INCIDENTAL, SPECIAL, INDIRECT, OR CONSEQUENTIAL DAMAGES WHATSOEVER, INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF PROFITS, LOSS OF DATA, BUSINESS INTERRUPTION, OR ANY OTHER COMMERCIAL DAMAGES OR LOSSES, ARISING OUT OF OR RELATED TO YOUR USE OF OR INABILITY TO USE THE LICENSED APPLICATION, HOWEVER CAUSED, REGARDLESS OF THE THEORY OF LIABILITY (CONTRACT, TORT, OR OTHERWISE) AND EVEN IF LICENSOR HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. SOME JURISDICTIONS DO NOT ALLOW THE LIMITATION OF LIABILITY FOR PERSONAL INJURY, OR OF INCIDENTAL OR CONSEQUENTIAL DAMAGES, SO THIS LIMITATION MAY NOT APPLY TO YOU. In no event shall Licensor\'s total liability to you for all damages (other than as may be required by applicable law in cases involving personal injury) exceed the amount of fifty dollars (\$50.00). The foregoing limitations will apply even if the above stated remedy fails of its essential purpose.'.tr,
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