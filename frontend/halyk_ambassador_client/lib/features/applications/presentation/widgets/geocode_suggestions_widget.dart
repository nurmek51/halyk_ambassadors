import 'package:flutter/material.dart';
import '../../domain/entities/application_entities.dart';

class GecodeSuggestionsWidget extends StatelessWidget {
  final List<GeocodeAddress> suggestions;
  final Function(GeocodeAddress) onSuggestionSelected;

  const GecodeSuggestionsWidget({
    super.key,
    required this.suggestions,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: suggestions.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            onTap: () => onSuggestionSelected(suggestion),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              suggestion.displayName,
              style: const TextStyle(
                fontFamily: 'Mabry Pro',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xDE000000),
                height: 1.30,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0x52000000),
            ),
          );
        },
      ),
    );
  }
}
