/// Countries offered in the Settings → streaming-region picker.
///
/// TMDb answers watch-provider queries for 111 countries. This is a curated
/// subset, for two reasons: a 111-row [SimpleDialog] is unusable without a
/// search field, and fetching TMDb's own `/watch/providers/regions` would mean
/// a second proxy allowlist entry, a second worker deploy, and a network wait
/// in front of a Settings row where every other row is instant — while still
/// not solving the naming problem below.
///
/// **Each country is named in its own language**, matching how the language
/// picker names languages ("Türkçe", not "Turkish"): someone who cannot read
/// the current UI language can still find their own country. It also means
/// these names need no ARB entries — otherwise this would be 111 × 2
/// translations, none of which any check could verify.
///
/// This list is a convenience, never a restriction. The picker unions it with
/// whatever the device reports (see `watchRegionOptions`), so a user in a
/// country that isn't here still gets the right catalogue and can still see
/// their region selected. Adding an entry here only makes it easier to *find*.
const Map<String, String> kWatchRegions = {
  'TR': 'Türkiye',
  'US': 'United States',
  'GB': 'United Kingdom',
  'DE': 'Deutschland',
  'FR': 'France',
  'IT': 'Italia',
  'ES': 'España',
  'PT': 'Portugal',
  'NL': 'Nederland',
  'BE': 'België',
  'AT': 'Österreich',
  'CH': 'Schweiz',
  'SE': 'Sverige',
  'NO': 'Norge',
  'DK': 'Danmark',
  'FI': 'Suomi',
  'PL': 'Polska',
  'CZ': 'Česko',
  'GR': 'Ελλάδα',
  'RU': 'Россия',
  'UA': 'Україна',
  'AZ': 'Azərbaycan',
  'CA': 'Canada',
  'MX': 'México',
  'BR': 'Brasil',
  'AR': 'Argentina',
  'AU': 'Australia',
  'NZ': 'New Zealand',
  'JP': '日本',
  'KR': '대한민국',
  'CN': '中国',
  'IN': 'भारत',
  'ID': 'Indonesia',
  'AE': 'الإمارات',
  'SA': 'السعودية',
  'IL': 'ישראל',
  'ZA': 'South Africa',
};

/// Display label for [code] — its own-language name when known, otherwise the
/// bare ISO code, which is still recognisable and always better than hiding
/// the country the user is actually in.
String watchRegionLabel(String code) => kWatchRegions[code] ?? code;
