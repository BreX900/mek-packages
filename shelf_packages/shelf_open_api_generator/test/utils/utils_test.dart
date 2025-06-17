import 'package:shelf_open_api_generator/src/utils/doc.dart';
import 'package:test/test.dart';

void main() {
  group('clean documentation', () {
    test('not returns anything because doc line is empty', () {
      final doc = Doc.clean('///');

      expect(doc, null);
    });

    test('not returns anything because doc line with space is empty', () {
      final doc = Doc.clean('/// ');

      expect(doc, null);
    });

    test('returns only doc text', () {
      final doc = Doc.clean('/// Ciao');

      expect(doc, 'Ciao');
    });

    test('not returns first and latest empty doc lines', () {
      final doc = Doc.clean('///\n///\n/// Ciao\n///\n/// ');

      expect(doc, 'Ciao');
    });
  });

  group('parse documentation', () {
    final summary = 'This is summary';
    final description = 'This is description\nThis is description';
    final exampleValue = 'example@email.com';
    final example = 'Example: `$exampleValue`';

    test('empty', () {
      final doc = Doc.from('');

      expect(doc.summary, null);
      expect(doc.description, null);
      expect(doc.example, null);
    });

    test('summary', () {
      final doc = Doc.from(summary);

      expect(doc.summary, summary);
      expect(doc.description, null);
      expect(doc.example, null);
    });

    test('description', () {
      final doc = Doc.from(description);

      expect(doc.summary, null);
      expect(doc.description, description);
      expect(doc.example, null);
    });

    test('summary - description', () {
      final doc = Doc.from('$summary\n\n$description');

      expect(doc.summary, summary);
      expect(doc.description, description);
      expect(doc.example, null);
    });

    test('summary - description - example', () {
      final doc = Doc.from('$summary\n\n$description\n$example');

      expect(doc.summary, summary);
      expect(doc.description, description);
      expect(doc.example, exampleValue);
    });
  });
}
