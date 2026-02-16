import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

/// Service pour gérer le cache local et le mode hors ligne
class OfflineCacheService {
  static final OfflineCacheService _instance = OfflineCacheService._internal();
  factory OfflineCacheService() => _instance;
  OfflineCacheService._internal();

  Database? _database;
  static const String _databaseName = 'campuslink_cache.db';
  static const int _databaseVersion = 1;

  /// Initialise la base de données locale
  Future<void> initialize() async {
    // sqflite ne fonctionne pas sur le web
    if (kIsWeb) {
      debugPrint('OfflineCacheService: sqflite not supported on web, skipping initialization');
      return;
    }
    
    if (_database != null) return;

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        // Table pour le cache des événements
        await db.execute('''
          CREATE TABLE events_cache (
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            updated_at INTEGER NOT NULL,
            expires_at INTEGER NOT NULL
          )
        ''');

        // Table pour le cache des groupes
        await db.execute('''
          CREATE TABLE groups_cache (
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            updated_at INTEGER NOT NULL,
            expires_at INTEGER NOT NULL
          )
        ''');

        // Table pour le cache des utilisateurs
        await db.execute('''
          CREATE TABLE users_cache (
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            updated_at INTEGER NOT NULL,
            expires_at INTEGER NOT NULL
          )
        ''');

        // Table pour le cache des messages
        await db.execute('''
          CREATE TABLE messages_cache (
            id TEXT PRIMARY KEY,
            conversation_id TEXT NOT NULL,
            data TEXT NOT NULL,
            updated_at INTEGER NOT NULL,
            expires_at INTEGER NOT NULL
          )
        ''');

        // Table pour le cache du feed
        await db.execute('''
          CREATE TABLE feed_cache (
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            updated_at INTEGER NOT NULL,
            expires_at INTEGER NOT NULL
          )
        ''');

        // Index pour améliorer les performances
        await db.execute('CREATE INDEX idx_messages_conversation ON messages_cache(conversation_id)');
        await db.execute('CREATE INDEX idx_events_expires ON events_cache(expires_at)');
        await db.execute('CREATE INDEX idx_groups_expires ON groups_cache(expires_at)');
      },
    );
  }

  /// Vérifie si une entrée est encore valide (non expirée)
  bool _isValid(int expiresAt) {
    return DateTime.now().millisecondsSinceEpoch < expiresAt;
  }

  /// Durée de validité du cache (24 heures par défaut)
  int _getExpirationTime({Duration? duration}) {
    final cacheDuration = duration ?? const Duration(hours: 24);
    return DateTime.now().add(cacheDuration).millisecondsSinceEpoch;
  }

  /// Sauvegarde des données dans le cache
  Future<void> saveToCache({
    required String table,
    required String id,
    required Map<String, dynamic> data,
    Duration? expiration,
  }) async {
    if (kIsWeb) return; // Pas de cache sur le web
    await initialize();
    if (_database == null) return;

    try {
      await _database!.insert(
        table,
        {
          'id': id,
          'data': jsonEncode(data),
          'updated_at': DateTime.now().millisecondsSinceEpoch,
          'expires_at': _getExpirationTime(duration: expiration),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Error saving to cache: $e');
    }
  }

  /// Récupère des données depuis le cache
  Future<Map<String, dynamic>?> getFromCache({
    required String table,
    required String id,
  }) async {
    if (kIsWeb) return null; // Pas de cache sur le web
    await initialize();
    if (_database == null) return null;

    try {
      final result = await _database!.query(
        table,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.isEmpty) return null;

      final row = result.first;
      final expiresAt = row['expires_at'] as int;

      if (!_isValid(expiresAt)) {
        // Supprimer l'entrée expirée
        await _database!.delete(table, where: 'id = ?', whereArgs: [id]);
        return null;
      }

      final dataStr = row['data'] as String;
      return jsonDecode(dataStr) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error getting from cache: $e');
      return null;
    }
  }

  /// Récupère toutes les entrées valides d'une table
  Future<List<Map<String, dynamic>>> getAllFromCache({
    required String table,
    String? orderBy,
    int? limit,
  }) async {
    if (kIsWeb) return []; // Pas de cache sur le web
    await initialize();
    if (_database == null) return [];

    try {
      // Nettoyer les entrées expirées
      final now = DateTime.now().millisecondsSinceEpoch;
      await _database!.delete(
        table,
        where: 'expires_at < ?',
        whereArgs: [now],
      );

      // Récupérer les entrées valides
      final results = await _database!.query(
        table,
        orderBy: orderBy ?? 'updated_at DESC',
        limit: limit,
      );

      return results.map((row) {
        final dataStr = row['data'] as String;
        return jsonDecode(dataStr) as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      debugPrint('Error getting all from cache: $e');
      return [];
    }
  }

  /// Sauvegarde une liste d'événements
  Future<void> saveEvents(List<Map<String, dynamic>> events) async {
    for (final event in events) {
      final id = event['id']?.toString() ?? '';
      if (id.isNotEmpty) {
        await saveToCache(
          table: 'events_cache',
          id: id,
          data: event,
          expiration: const Duration(hours: 24),
        );
      }
    }
  }

  /// Récupère les événements depuis le cache
  Future<List<Map<String, dynamic>>> getCachedEvents({int? limit}) async {
    return await getAllFromCache(
      table: 'events_cache',
      orderBy: 'updated_at DESC',
      limit: limit,
    );
  }

  /// Sauvegarde une liste de groupes
  Future<void> saveGroups(List<Map<String, dynamic>> groups) async {
    for (final group in groups) {
      final id = group['id']?.toString() ?? '';
      if (id.isNotEmpty) {
        await saveToCache(
          table: 'groups_cache',
          id: id,
          data: group,
          expiration: const Duration(hours: 24),
        );
      }
    }
  }

  /// Récupère les groupes depuis le cache
  Future<List<Map<String, dynamic>>> getCachedGroups({int? limit}) async {
    return await getAllFromCache(
      table: 'groups_cache',
      orderBy: 'updated_at DESC',
      limit: limit,
    );
  }

  /// Sauvegarde une liste d'utilisateurs
  Future<void> saveUsers(List<Map<String, dynamic>> users) async {
    for (final user in users) {
      final id = user['id']?.toString() ?? '';
      if (id.isNotEmpty) {
        await saveToCache(
          table: 'users_cache',
          id: id,
          data: user,
          expiration: const Duration(hours: 12),
        );
      }
    }
  }

  /// Récupère les utilisateurs depuis le cache
  Future<List<Map<String, dynamic>>> getCachedUsers({int? limit}) async {
    return await getAllFromCache(
      table: 'users_cache',
      orderBy: 'updated_at DESC',
      limit: limit,
    );
  }

  /// Sauvegarde des messages
  Future<void> saveMessages(String conversationId, List<Map<String, dynamic>> messages) async {
    for (final message in messages) {
      final id = message['id']?.toString() ?? '';
      if (id.isNotEmpty) {
        await saveToCache(
          table: 'messages_cache',
          id: '$conversationId:$id',
          data: {...message, 'conversation_id': conversationId},
          expiration: const Duration(days: 7),
        );
      }
    }
  }

  /// Récupère les messages depuis le cache
  Future<List<Map<String, dynamic>>> getCachedMessages(String conversationId) async {
    if (kIsWeb) return []; // Pas de cache sur le web
    await initialize();
    if (_database == null) return [];

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await _database!.delete(
        'messages_cache',
        where: 'expires_at < ?',
        whereArgs: [now],
      );

      final results = await _database!.query(
        'messages_cache',
        where: 'conversation_id = ?',
        whereArgs: [conversationId],
        orderBy: 'updated_at ASC',
      );

      return results.map((row) {
        final dataStr = row['data'] as String;
        return jsonDecode(dataStr) as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      debugPrint('Error getting cached messages: $e');
      return [];
    }
  }

  /// Sauvegarde le feed
  Future<void> saveFeed(List<Map<String, dynamic>> feedItems) async {
    for (int i = 0; i < feedItems.length; i++) {
      final item = feedItems[i];
      await saveToCache(
        table: 'feed_cache',
        id: 'feed_item_$i',
        data: item,
        expiration: const Duration(hours: 6),
      );
    }
  }

  /// Récupère le feed depuis le cache
  Future<List<Map<String, dynamic>>> getCachedFeed({int? limit}) async {
    return await getAllFromCache(
      table: 'feed_cache',
      orderBy: 'updated_at DESC',
      limit: limit,
    );
  }

  /// Nettoie le cache expiré
  Future<void> cleanExpiredCache() async {
    if (kIsWeb) return; // Pas de cache sur le web
    await initialize();
    if (_database == null) return;

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final tables = ['events_cache', 'groups_cache', 'users_cache', 'messages_cache', 'feed_cache'];
      
      for (final table in tables) {
        await _database!.delete(
          table,
          where: 'expires_at < ?',
          whereArgs: [now],
        );
      }
    } catch (e) {
      debugPrint('Error cleaning cache: $e');
    }
  }

  /// Vide tout le cache
  Future<void> clearAllCache() async {
    if (kIsWeb) return; // Pas de cache sur le web
    await initialize();
    if (_database == null) return;

    try {
      final tables = ['events_cache', 'groups_cache', 'users_cache', 'messages_cache', 'feed_cache'];
      for (final table in tables) {
        await _database!.delete(table);
      }
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Ferme la base de données
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

