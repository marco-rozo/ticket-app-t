import 'package:code_bar_reader_base/core/theme/components/custom_button/custom_button.dart';
import 'package:code_bar_reader_base/core/theme/components/custom_text_form_field/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ManualInsertionBodyWidget extends StatelessWidget {
  final TextEditingController codeTextController = TextEditingController();
  ManualInsertionBodyWidget({
    super.key,
    required codeTextController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Código do ticket'),
        const SizedBox(height: 8),
        CustomTextFormField(
          textEditingController: codeTextController,
          textCapitalization: TextCapitalization.characters,
          hintText: 'Código',
        ),
        const SizedBox(height: 16),
        CustomButton.primary(
          text: 'Confirmar',
          onPressed: () {
            context.pop(codeTextController.value.text);
          },
        ),
      ],
    );
  }
}
