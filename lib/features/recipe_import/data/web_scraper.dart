import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

class WebScraper {
  // Returns a map with keys: title, ingredients (List<String>), instructions(List<String>), yield, imageUrl
  Future<Map<String, dynamic>> scrapeRecipe(String url) async {
    final result = {
      'title': null,
      'ingredients': <String>[],
      'instructions': <String>[],
      'yield': null,
      'imageUrl': null,
      'sourceUrl': url,
    };

    try {
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode != 200) return result;

      final doc = html_parser.parse(resp.body);

      // title: og:title -> meta property or h1
      final metaOgTitle = doc
          .querySelector('meta[property="og:title"]')
          ?.attributes['content'];
      final h1 = doc.querySelector('h1')?.text;
      result['title'] = (metaOgTitle ?? h1 ?? '').trim();

      // image: og:image
      final ogImage = doc
          .querySelector('meta[property="og:image"]')
          ?.attributes['content'];
      result['imageUrl'] = ogImage;

      // ingredients heuristics: any list items with class containing 'ingredient'
      final ingredientNodes = <Element>[];
      ingredientNodes.addAll(doc.querySelectorAll('[class*="ingredient"] li'));
      if (ingredientNodes.isEmpty) {
        ingredientNodes.addAll(doc.querySelectorAll('ul.ingredients li'));
      }
      if (ingredientNodes.isEmpty) {
        // fallback: look for lists under sections with 'ingredients' id/class
        ingredientNodes.addAll(
          doc.querySelectorAll('#ingredients li, .ingredients li'),
        );
      }
      if (ingredientNodes.isNotEmpty) {
        result['ingredients'] = ingredientNodes
            .map((e) => e.text.trim())
            .where((t) => t.isNotEmpty)
            .toList();
      }

      // instructions heuristics: ordered lists with 'instruction' or steps
      final instructionNodes = <Element>[];
      instructionNodes.addAll(
        doc.querySelectorAll('[class*="instruction"] li'),
      );
      instructionNodes.addAll(doc.querySelectorAll('ol.instructions li'));
      instructionNodes.addAll(
        doc.querySelectorAll('#directions li, .directions li'),
      );
      if (instructionNodes.isNotEmpty) {
        result['instructions'] = instructionNodes
            .map((e) => e.text.trim())
            .where((t) => t.isNotEmpty)
            .toList();
      } else {
        // Try paragraphs under 'instructions' section
        final instrSection = doc.querySelector(
          '.instructions, #instructions, .method, #method',
        );
        if (instrSection != null) {
          result['instructions'] = instrSection
              .querySelectorAll('p')
              .map((p) => p.text.trim())
              .where((t) => t.isNotEmpty)
              .toList();
        }
      }

      // yield: look for 'yield' or 'servings'
      final yieldText = doc.querySelectorAll('*').firstWhere((e) {
        final text = e.text.toLowerCase();
        return text.contains('yield') ||
            text.contains('servings') ||
            text.contains('makes');
      }, orElse: () => Element.tag('span')).text;
      if (yieldText.isNotEmpty) {
        result['yield'] = yieldText.trim();
      }
    } catch (e) {
      // swallow errors; caller will show review UI so user can correct
    }

    return result;
  }
}
