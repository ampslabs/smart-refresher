/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-09-06 11:18 PM
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Implementation of localized strings for ClassicHeader, ClassicFooter, and TwoLevelHeader.
///
/// Supported languages include Chinese, English, French, Russian, Ukrainian, Italian, Japanese, German, Spanish, Dutch, Swedish, Portuguese, and Korean.
///
/// ## Sample code
///
/// To include the localizations provided by this class in a [MaterialApp],
/// add [RefreshLocalizations.delegate] to [MaterialApp.localizationsDelegates],
/// and specify the locales your app supports with [MaterialApp.supportedLocales]:
///
/// ```dart
/// MaterialApp(
///   localizationsDelegates: [
///     RefreshLocalizations.delegate,
///     // ... other delegates
///   ],
///   supportedLocales: [
///     const Locale('en'),
///     const Locale('zh'),
///     // ...
///   ],
///   // ...
/// )
/// ```
class RefreshLocalizations {
  /// The locale for which the strings are provided.
  final Locale locale;

  /// Creates a [RefreshLocalizations] for the given [locale].
  RefreshLocalizations(this.locale);

  /// A map of language codes to their corresponding [RefreshString] implementations.
  Map<String, RefreshString> values = {
    'en': EnRefreshString(),
    'zh': ChRefreshString(),
    'fr': FrRefreshString(),
    'ru': RuRefreshString(),
    'uk': UkRefreshString(),
    'it': ItRefreshString(),
    'ja': JpRefreshString(),
    'de': DeRefreshString(),
    'es': EsRefreshString(),
    'nl': NlRefreshString(),
    'sv': SvRefreshString(),
    'pt': PtRefreshString(),
    'ko': KrRefreshString(),
  };

  /// Returns the localized strings for the current [locale].
  ///
  /// Defaults to English if the locale is not supported.
  RefreshString? get currentLocalization {
    if (values.containsKey(locale.languageCode)) {
      return values[locale.languageCode];
    }
    return values['en'];
  }

  /// The delegate for [RefreshLocalizations].
  static const RefreshLocalizationsDelegate delegate =
      RefreshLocalizationsDelegate();

  /// Returns the [RefreshLocalizations] instance from the given [context].
  static RefreshLocalizations? of(BuildContext context) {
    return Localizations.of(context, RefreshLocalizations);
  }
}

/// A delegate for [RefreshLocalizations] that can be used in [MaterialApp.localizationsDelegates].
class RefreshLocalizationsDelegate
    extends LocalizationsDelegate<RefreshLocalizations> {
  /// Creates a [RefreshLocalizationsDelegate].
  const RefreshLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return [
      'en',
      'zh',
      'fr',
      'ru',
      'uk',
      'ja',
      'it',
      'de',
      'ko',
      'pt',
      'sv',
      'nl',
      'es'
    ].contains(locale.languageCode);
  }

  @override
  Future<RefreshLocalizations> load(Locale locale) {
    return SynchronousFuture<RefreshLocalizations>(
        RefreshLocalizations(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<RefreshLocalizations> old) {
    return false;
  }
}

/// An interface for providing localized strings for refresh indicators.
abstract class RefreshString {
  /// Text shown when the header is in the idle refresh state.
  String? idleRefreshText;

  /// Text shown when the user has dragged far enough to trigger a refresh.
  String? canRefreshText;

  /// Text shown while the header is refreshing.
  String? refreshingText;

  /// Text shown when the refresh is successfully completed.
  String? refreshCompleteText;

  /// Text shown when the refresh process fails.
  String? refreshFailedText;

  /// Text shown when the user has dragged far enough to trigger the two-level mode.
  String? canTwoLevelText;

  /// Text shown when the footer is in the idle loading state.
  String? idleLoadingText;

  /// Text shown when the user has dragged far enough to trigger loading more data.
  String? canLoadingText;

  /// Text shown while the footer is loading.
  String? loadingText;

  /// Text shown when the loading process fails.
  String? loadFailedText;

  /// Text shown when there is no more data to load.
  String? noMoreText;
}

/// Chinese implementation of [RefreshString].
class ChRefreshString implements RefreshString {
  @override
  String? canLoadingText = '松手开始加载数据';

  @override
  String? canRefreshText = '松开开始刷新数据';

  @override
  String? canTwoLevelText = '释放手势,进入二楼';

  @override
  String? idleLoadingText = '上拉加载';

  @override
  String? idleRefreshText = '下拉刷新';

  @override
  String? loadFailedText = '加载失败';

  @override
  String? loadingText = '加载中…';

  @override
  String? noMoreText = '没有更多数据了';

  @override
  String? refreshCompleteText = '刷新成功';

  @override
  String? refreshFailedText = '刷新失败';

  @override
  String? refreshingText = '刷新中…';
}

/// English implementation of [RefreshString].
class EnRefreshString implements RefreshString {
  @override
  String? canLoadingText = 'Release to load more';

  @override
  String? canRefreshText = 'Release to refresh';

  @override
  String? canTwoLevelText = 'Release to enter secondfloor';

  @override
  String? idleLoadingText = 'Pull up Load more';

  @override
  String? idleRefreshText = 'Pull down Refresh';

  @override
  String? loadFailedText = 'Load Failed';

  @override
  String? loadingText = 'Loading…';

  @override
  String? noMoreText = 'No more data';

  @override
  String? refreshCompleteText = 'Refresh completed';

  @override
  String? refreshFailedText = 'Refresh failed';

  @override
  String? refreshingText = 'Refreshing…';
}

/// French implementation of [RefreshString].
class FrRefreshString implements RefreshString {
  @override
  String? canLoadingText = 'Relâchez pour charger davantage';

  @override
  String? canRefreshText = 'Relâchez pour rafraîchir';

  @override
  String? canTwoLevelText = 'Relâchez pour entrer secondfloor';

  @override
  String? idleLoadingText = 'Tirez pour charger davantage';

  @override
  String? idleRefreshText = 'Tirez pour rafraîchir';

  @override
  String? loadFailedText = 'Chargement échoué';

  @override
  String? loadingText = 'Chargement…';

  @override
  String? noMoreText = 'Aucune autre donnée';

  @override
  String? refreshCompleteText = 'Rafraîchissement terminé';

  @override
  String? refreshFailedText = 'Rafraîchissement échoué';

  @override
  String? refreshingText = 'Rafraîchissement…';
}

/// Russian implementation of [RefreshString].
class RuRefreshString implements RefreshString {
  @override
  String? canLoadingText = 'Отпустите, чтобы загрузить больше';

  @override
  String? canRefreshText = 'Отпустите, чтобы обновить';

  @override
  String? canTwoLevelText = 'Отпустите, чтобы войти на второй уровень';

  @override
  String? idleLoadingText = 'Тянуть вверх, чтобы загрузить больше';

  @override
  String? idleRefreshText = 'Тянуть вниз, чтобы обновить';

  @override
  String? loadFailedText = 'Ошибка загрузки';

  @override
  String? loadingText = 'Загрузка…';

  @override
  String? noMoreText = 'Больше данных нет';

  @override
  String? refreshCompleteText = 'Обновление завершено';

  @override
  String? refreshFailedText = 'Не удалось обновить';

  @override
  String? refreshingText = 'Обновление…';
}

/// Ukrainian implementation of [RefreshString].
class UkRefreshString implements RefreshString {
  @override
  String? canLoadingText = 'Відпустіть, щоб завантажити більше';

  @override
  String? canRefreshText = 'Відпустіть, щоб оновити';

  @override
  String? canTwoLevelText = 'Відпустіть, щоб увійти на другий рівень';

  @override
  String? idleLoadingText = 'Тягнути вгору, щоб завантажити більше';

  @override
  String? idleRefreshText = 'Тягнути вниз, щоб оновити';

  @override
  String? loadFailedText = 'Помилка завантаження';

  @override
  String? loadingText = 'Завантаження…';

  @override
  String? noMoreText = 'Більше даних немає';

  @override
  String? refreshCompleteText = 'Оновлення завершено';

  @override
  String? refreshFailedText = 'Не вдалося оновити';

  @override
  String? refreshingText = 'Оновлення…';
}

/// Italian implementation of [RefreshString].
class ItRefreshString implements RefreshString {
  @override
  String? canLoadingText = 'Rilascia per caricare altro';

  @override
  String? canRefreshText = 'Rilascia per aggiornare';

  @override
  String? canTwoLevelText = 'Rilascia per accedere a secondfloor';

  @override
  String? idleLoadingText = 'Tira per caricare altro';

  @override
  String? idleRefreshText = 'Tira giù per aggiornare';

  @override
  String? loadFailedText = 'Caricamento fallito';

  @override
  String? loadingText = 'Caricamento…';

  @override
  String? noMoreText = 'Nessun altro elemento';

  @override
  String? refreshCompleteText = 'Aggiornamento completato';

  @override
  String? refreshFailedText = 'Aggiornamento fallito';

  @override
  String? refreshingText = 'Aggiornamento…';
}

/// Japanese implementation of [RefreshString].
class JpRefreshString implements RefreshString {
  @override
  String? canLoadingText = '指を離して更に読み込む';

  @override
  String? canRefreshText = '指を離して更新';

  @override
  String? canTwoLevelText = '指を離して2段目を表示';

  @override
  String? idleLoadingText = '上方スワイプで更に読み込む';

  @override
  String? idleRefreshText = '下方スワイプでデータを更新';

  @override
  String? loadFailedText = '読み込みが失敗しました';

  @override
  String? loadingText = '読み込み中…';

  @override
  String? noMoreText = 'データはありません';

  @override
  String? refreshCompleteText = '更新完了';

  @override
  String? refreshFailedText = '更新が失敗しました';

  @override
  String? refreshingText = '更新中…';
}

/// German implementation of [RefreshString].
class DeRefreshString implements RefreshString {
  @override
  String? canLoadingText = 'Loslassen, um mehr zu laden';

  @override
  String? canRefreshText = 'Zum Aktualisieren loslassen';

  @override
  String? canTwoLevelText = 'Lassen Sie los, um den zweiten Stock zu betreten';

  @override
  String? idleLoadingText = 'Hochziehen, mehr laden';

  @override
  String? idleRefreshText = 'Ziehen für Aktualisierung';

  @override
  String? loadFailedText = 'Laden ist fehlgeschlagen';

  @override
  String? loadingText = 'Lade…';

  @override
  String? noMoreText = 'Keine weitere Daten';

  @override
  String? refreshCompleteText = 'Aktualisierung fertig';

  @override
  String? refreshFailedText = 'Aktualisierung fehlgeschlagen';

  @override
  String? refreshingText = 'Aktualisiere…';
}

/// Spanish implementation of [RefreshString].
class EsRefreshString implements RefreshString {
  @override
  String? canLoadingText = 'Suelte para cargar más';

  @override
  String? canRefreshText = 'Suelte para actualizar';

  @override
  String? canTwoLevelText = 'Suelte para entrar al secondfloor';

  @override
  String? idleLoadingText = 'Tire hacia arriba para cargar más';

  @override
  String? idleRefreshText = 'Tire hacia abajo para refrescar';

  @override
  String? loadFailedText = 'Error de carga';

  @override
  String? loadingText = 'Cargando…';

  @override
  String? noMoreText = 'No hay más datos disponibles';

  @override
  String? refreshCompleteText = 'Actualización completada';

  @override
  String? refreshFailedText = 'Error al actualizar';

  @override
  String? refreshingText = 'Actualizando…';
}

/// Dutch implementation of [RefreshString].
class NlRefreshString implements RefreshString {
  @override
  String? canLoadingText = 'Laat los om meer te laden';

  @override
  String? canRefreshText = 'Laat los om te vernieuwen';

  @override
  String? canTwoLevelText = 'Laat los om naar secondfloor te gaan';

  @override
  String? idleLoadingText = 'Trek omhoog om meer te laden';

  @override
  String? idleRefreshText = 'Trek omlaag om te vernieuwen';

  @override
  String? loadFailedText = 'Laden mislukt';

  @override
  String? loadingText = 'Laden…';

  @override
  String? noMoreText = 'Geen data meer';

  @override
  String? refreshCompleteText = 'Vernieuwen voltooid';

  @override
  String? refreshFailedText = 'Vernieuwen mislukt';

  @override
  String? refreshingText = 'Vernieuwen…';
}

/// Swedish implementation of [RefreshString].
class SvRefreshString implements RefreshString {
  @override
  String? canLoadingText = 'Släpp för att ladda mer';

  @override
  String? canRefreshText = 'Släpp för att uppdatera';

  @override
  String? canTwoLevelText = 'Släpp för att gå till secondfloor';

  @override
  String? idleLoadingText = 'Dra upp för att ladda mer';

  @override
  String? idleRefreshText = 'Dra ner för att uppdatera';

  @override
  String? loadFailedText = 'Hämtningen misslyckades';

  @override
  String? loadingText = 'Laddar…';

  @override
  String? noMoreText = 'Ingen mer data';

  @override
  String? refreshCompleteText = 'Uppdaterad';

  @override
  String? refreshFailedText = 'Kunde inte uppdatera';

  @override
  String? refreshingText = 'Uppdaterar…';
}

/// Portuguese implementation of [RefreshString].
class PtRefreshString implements RefreshString {
  @override
  String? canLoadingText = 'Solte para carregar mais';

  @override
  String? canRefreshText = 'Solte para atualizar';

  @override
  String? canTwoLevelText = 'Solte para entrar no secondfloor';

  @override
  String? idleLoadingText = 'Puxe para cima para carregar mais';

  @override
  String? idleRefreshText = 'Puxe para baixo para atualizar';

  @override
  String? loadFailedText = 'Falha ao carregar';

  @override
  String? loadingText = 'Carregando…';

  @override
  String? noMoreText = 'Não há mais dados';

  @override
  String? refreshCompleteText = 'Atualização completada';

  @override
  String? refreshFailedText = 'Falha ao atualizar';

  @override
  String? refreshingText = 'Atualizando…';
}

/// Korean implementation of [RefreshString].
class KrRefreshString implements RefreshString {
  @override
  String? canLoadingText = '당겨서 불러오기';

  @override
  String? canRefreshText = '당겨서 새로 고침';

  @override
  String? canTwoLevelText = '두 번째 레벨로 이동';

  @override
  String? idleLoadingText = '위로 당겨서 불러오기';

  @override
  String? idleRefreshText = '아래로 당겨서 새로 고침';

  @override
  String? loadFailedText = '로딩에 실패했습니다.';

  @override
  String? loadingText = '로딩 중…';

  @override
  String? noMoreText = '데이터가 더 이상 없습니다.';

  @override
  String? refreshCompleteText = '새로 고침 완료';

  @override
  String? refreshFailedText = '새로 고침에 실패했습니다.';

  @override
  String? refreshingText = '새로 고침 중…';
}
