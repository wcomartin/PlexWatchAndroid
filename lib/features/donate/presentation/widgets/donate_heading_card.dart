import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../translations/locale_keys.g.dart';

class DonateHeadingCard extends StatelessWidget {
  const DonateHeadingCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  LocaleKeys.donate_heading_card_title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ).tr(),
                const Gap(8),
                const Text(
                  LocaleKeys.donate_heading_card_content,
                  textAlign: TextAlign.center,
                ).tr(),
              ],
            ),
          ),
        ),
        const Gap(4),
        const Divider(
          indent: 32,
          endIndent: 32,
        ),
        const Gap(4),
      ],
    );
  }
}
