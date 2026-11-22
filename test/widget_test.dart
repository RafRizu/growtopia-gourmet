import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:growtopia_gourmet/main.dart';
import 'package:growtopia_gourmet/pages/katalog_page.dart';
import 'package:growtopia_gourmet/widgets/menu_card.dart';
import 'package:growtopia_gourmet/widgets/radial_hero.dart';
import 'package:growtopia_gourmet/widgets/rotating_cup_header.dart';

void main() {
  testWidgets(
    'KatalogPage renders 10 dishes, RotatingCupHeader with RepaintBoundary, and no Opacity on available cards',
    (WidgetTester tester) async {
      await tester.pumpWidget(const GrowtopiaGourmetApp());
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Growtopia Gourmet'), findsOneWidget);
      expect(find.byType(RotatingCupHeader), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(RotatingCupHeader),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Arroz con Pollo'), findsOneWidget);
      expect(find.text('25 WL'), findsOneWidget);

      // Available menu cards must never be wrapped in Opacity or AnimatedOpacity.
      expect(
        find.descendant(
          of: find.byType(MenuCard),
          matching: find.byType(AnimatedOpacity),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(MenuCard),
          matching: find.byType(Opacity),
        ),
        findsNothing,
      );

      // Scroll down to verify the 10th dish exists in ListView.builder.
      await tester.scrollUntilVisible(
        find.text('Pineapple Turnover'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Pineapple Turnover'), findsOneWidget);
    },
  );

  testWidgets(
    'Long press toggles availability with 400ms AnimatedOpacity 0.4 and HABIS badge',
    (WidgetTester tester) async {
      await tester.pumpWidget(const GrowtopiaGourmetApp());
      await tester.pump(const Duration(milliseconds: 50));

      final Finder firstCard = find.byType(MenuCard).first;
      await tester.longPress(firstCard);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));

      final Finder animatedOpacityFinder = find.descendant(
        of: firstCard,
        matching: find.byType(AnimatedOpacity),
      );
      expect(animatedOpacityFinder, findsOneWidget);
      final AnimatedOpacity opacityWidget =
          tester.widget<AnimatedOpacity>(animatedOpacityFinder);
      expect(opacityWidget.opacity, 0.4);
      expect(opacityWidget.duration, const Duration(milliseconds: 400));
      expect(find.text('HABIS'), findsOneWidget);
      expect(find.text('Tersedia (9)'), findsOneWidget);
      expect(find.text('Habis (1)'), findsOneWidget);

      // Tapping an unavailable card must not open DetailPage.
      await tester.tap(firstCard);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Detail Hidangan'), findsNothing);

      // Long press again restores availability and removes AnimatedOpacity.
      await tester.longPress(firstCard);
      await tester.pump(const Duration(milliseconds: 100));
      expect(animatedOpacityFinder, findsNothing);
      expect(find.text('HABIS'), findsNothing);
      expect(find.text('Tersedia (10)'), findsOneWidget);
    },
  );

  testWidgets(
    'Tap available card opens DetailPage with RadialHero and working order sheet',
    (WidgetTester tester) async {
      await tester.pumpWidget(const GrowtopiaGourmetApp());
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.text('Arroz con Pollo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 650));

      expect(find.text('Detail Hidangan'), findsOneWidget);
      expect(find.byType(RadialHeroWidget), findsOneWidget);
      expect(find.text('TERSEDIA'), findsOneWidget);

      await tester.tap(find.text('Pesan Arroz con Pollo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Konfirmasi Pesanan'), findsOneWidget);
      expect(find.text('25 WL'), findsWidgets);

      await tester.tap(find.byTooltip('Tambah jumlah'));
      await tester.pump();
      expect(find.text('Catat Pesanan (50 WL)'), findsOneWidget);

      await tester.tap(find.text('Catat Pesanan (50 WL)'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.text('Pesanan dicatat: 2 x Arroz con Pollo (50 WL).'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Filter tabs, search, empty state, error state, and cup pause toggle work cleanly',
    (WidgetTester tester) async {
      await tester.pumpWidget(const GrowtopiaGourmetApp());
      await tester.pump(const Duration(milliseconds: 50));

      // Pause and resume rotating cup header.
      await tester.tap(find.byType(RotatingCupHeader));
      await tester.pump();
      expect(find.byTooltip('Putar cangkir'), findsOneWidget);
      await tester.tap(find.byType(RotatingCupHeader));
      await tester.pump();
      expect(find.byTooltip('Jeda rotasi cangkir'), findsOneWidget);

      // Empty state via Habis filter when all items are available.
      await tester.tap(find.text('Habis (0)'));
      await tester.pump();
      expect(find.text('Belum ada menu yang habis'), findsOneWidget);

      await tester.tap(find.text('Tampilkan semua menu'));
      await tester.pump();
      expect(find.text('Arroz con Pollo'), findsOneWidget);

      // Search filtering and clear button.
      await tester.enterText(find.byType(TextField), 'Gemonade');
      await tester.pump();
      expect(
        find.descendant(
          of: find.byType(MenuCard),
          matching: find.text('Gemonade'),
        ),
        findsOneWidget,
      );
      expect(find.text('Arroz con Pollo'), findsNothing);

      await tester.tap(find.byTooltip('Hapus pencarian'));
      await tester.pump();
      expect(find.text('Arroz con Pollo'), findsOneWidget);

      // Error state and reload action.
      await tester.pumpWidget(
        const MaterialApp(
          home: KatalogPage(initialError: 'Gagal membaca data lokal.'),
        ),
      );
      await tester.pump();
      expect(find.text('Katalog gagal dimuat'), findsOneWidget);
      expect(find.text('Gagal membaca data lokal.'), findsOneWidget);

      await tester.tap(find.text('Muat ulang katalog'));
      await tester.pump();
      expect(find.text('Memuat katalog menu Growtopia...'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Arroz con Pollo'), findsOneWidget);
    },
  );

  testWidgets(
    'Responsive layout holds without overflow on phone (390px) and desktop (1280px)',
    (WidgetTester tester) async {
      for (final Size size in const <Size>[Size(390, 844), Size(1280, 800)]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const GrowtopiaGourmetApp());
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Arroz con Pollo'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 650));
        expect(tester.takeException(), isNull);
        expect(find.text('Detail Hidangan'), findsOneWidget);
      }
    },
  );
}
