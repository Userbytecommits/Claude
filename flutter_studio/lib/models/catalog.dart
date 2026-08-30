import 'package:flutter/material.dart';
import 'canvas_element.dart';

const String kCategoryBasics = 'Basis';
const String kCategoryInput = 'Eingabe';
const String kCategoryDisplay = 'Anzeige';

const List<String> kCategories = [
  kCategoryBasics,
  kCategoryInput,
  kCategoryDisplay,
];

/// Alle im Katalog verfügbaren Widget-Typen mit sinnvollen Startwerten.
final List<CatalogItem> kCatalogItems = [
  CatalogItem(
    type: 'text',
    label: 'Text',
    category: kCategoryBasics,
    iconCodePoint: Icons.text_fields.codePoint,
    defaultWidth: 140,
    defaultHeight: 40,
    defaultProperties: () => {
      'text': 'Text',
      'fontSize': 16.0,
      'bold': false,
      'italic': false,
      'color': Colors.black.value,
      'textAlign': 'left',
    },
  ),
  CatalogItem(
    type: 'button',
    label: 'Button',
    category: kCategoryBasics,
    iconCodePoint: Icons.smart_button.codePoint,
    defaultWidth: 160,
    defaultHeight: 48,
    defaultProperties: () => {
      'text': 'Button',
      'color': Colors.white.value,
      'backgroundColor': Colors.indigo.value,
      'borderRadius': 12.0,
      'fontSize': 16.0,
    },
  ),
  CatalogItem(
    type: 'container',
    label: 'Box',
    category: kCategoryBasics,
    iconCodePoint: Icons.crop_square.codePoint,
    defaultWidth: 160,
    defaultHeight: 100,
    defaultProperties: () => {
      'backgroundColor': Colors.blueGrey.shade100.value,
      'borderRadius': 8.0,
      'borderWidth': 0.0,
      'borderColor': Colors.black.value,
      'opacity': 1.0,
    },
  ),
  CatalogItem(
    type: 'divider',
    label: 'Trenner',
    category: kCategoryBasics,
    iconCodePoint: Icons.horizontal_rule.codePoint,
    defaultWidth: 260,
    defaultHeight: 16,
    defaultProperties: () => {
      'color': Colors.grey.value,
      'thickness': 1.0,
    },
  ),
  CatalogItem(
    type: 'textfield',
    label: 'Eingabefeld',
    category: kCategoryInput,
    iconCodePoint: Icons.edit.codePoint,
    defaultWidth: 220,
    defaultHeight: 56,
    defaultProperties: () => {
      'hint': 'Eingabe...',
      'borderRadius': 8.0,
    },
  ),
  CatalogItem(
    type: 'switch',
    label: 'Schalter',
    category: kCategoryInput,
    iconCodePoint: Icons.toggle_on.codePoint,
    defaultWidth: 60,
    defaultHeight: 40,
    defaultProperties: () => {
      'value': true,
      'activeColor': Colors.indigo.value,
    },
  ),
  CatalogItem(
    type: 'checkbox',
    label: 'Checkbox',
    category: kCategoryInput,
    iconCodePoint: Icons.check_box.codePoint,
    defaultWidth: 40,
    defaultHeight: 40,
    defaultProperties: () => {
      'value': true,
      'activeColor': Colors.indigo.value,
    },
  ),
  CatalogItem(
    type: 'slider',
    label: 'Slider',
    category: kCategoryInput,
    iconCodePoint: Icons.tune.codePoint,
    defaultWidth: 200,
    defaultHeight: 40,
    defaultProperties: () => {
      'value': 0.5,
      'activeColor': Colors.indigo.value,
    },
  ),
  CatalogItem(
    type: 'image',
    label: 'Bild',
    category: kCategoryDisplay,
    iconCodePoint: Icons.image.codePoint,
    defaultWidth: 160,
    defaultHeight: 120,
    defaultProperties: () => {
      'imageUrl': 'https://picsum.photos/400',
      'borderRadius': 8.0,
      'fit': 'cover',
    },
  ),
  CatalogItem(
    type: 'icon',
    label: 'Icon',
    category: kCategoryDisplay,
    iconCodePoint: Icons.star.codePoint,
    defaultWidth: 48,
    defaultHeight: 48,
    defaultProperties: () => {
      'iconCodePoint': Icons.star.codePoint,
      'color': Colors.amber.value,
      'size': 40.0,
    },
  ),
  CatalogItem(
    type: 'card',
    label: 'Karte',
    category: kCategoryDisplay,
    iconCodePoint: Icons.credit_card.codePoint,
    defaultWidth: 200,
    defaultHeight: 120,
    defaultProperties: () => {
      'backgroundColor': Colors.white.value,
      'elevation': 4.0,
      'borderRadius': 12.0,
    },
  ),
  CatalogItem(
    type: 'listtile',
    label: 'Listeneintrag',
    category: kCategoryDisplay,
    iconCodePoint: Icons.list.codePoint,
    defaultWidth: 260,
    defaultHeight: 64,
    defaultProperties: () => {
      'title': 'Titel',
      'subtitle': 'Untertitel',
      'iconCodePoint': Icons.person.codePoint,
    },
  ),
];

CatalogItem catalogItemFor(String type) =>
    kCatalogItems.firstWhere((c) => c.type == type);
