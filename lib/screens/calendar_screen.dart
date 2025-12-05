import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../utils/app_colors.dart';
import 'event_detail_screen.dart';

/// Écran de calendrier des événements
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final EventService _eventService = EventService();
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  List<Event> _events = [];
  bool _isLoading = false;
  Map<DateTime, List<Event>> _eventsByDate = {};

  @override
  void initState() {
    super.initState();
    _loadCalendarEvents();
  }

  Future<void> _loadCalendarEvents() async {
    setState(() => _isLoading = true);
    try {
      // Calculer le début et la fin du mois
      final monthStart = DateTime(_currentMonth.year, _currentMonth.month, 1);
      final monthEnd = DateTime(_currentMonth.year, _currentMonth.month + 1, 0, 23, 59, 59);

      final events = await _eventService.getCalendarEvents(
        startDate: monthStart.toIso8601String(),
        endDate: monthEnd.toIso8601String(),
      );

      // Grouper les événements par date
      final eventsByDate = <DateTime, List<Event>>{};
      for (final event in events) {
        final eventDate = DateTime(
          event.startDate.year,
          event.startDate.month,
          event.startDate.day,
        );
        if (!eventsByDate.containsKey(eventDate)) {
          eventsByDate[eventDate] = [];
        }
        eventsByDate[eventDate]!.add(event);
      }

      setState(() {
        _events = events;
        _eventsByDate = eventsByDate;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading calendar events: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _selectedDate = DateTime(_currentMonth.year, _currentMonth.month, 1);
    });
    _loadCalendarEvents();
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _selectedDate = DateTime(_currentMonth.year, _currentMonth.month, 1);
    });
    _loadCalendarEvents();
  }

  void _goToToday() {
    setState(() {
      _currentMonth = DateTime.now();
      _selectedDate = DateTime.now();
    });
    _loadCalendarEvents();
  }

  List<Event> _getEventsForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return _eventsByDate[dateKey] ?? [];
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return _isSameDay(date, now);
  }

  bool _isSelected(DateTime date) {
    return _isSameDay(date, _selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: _goToToday,
            tooltip: 'Aujourd\'hui',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // En-tête du calendrier
                _buildCalendarHeader(),
                // Calendrier
                Expanded(
                  child: _buildCalendar(),
                ),
                // Liste des événements du jour sélectionné
                _buildSelectedDayEvents(),
              ],
            ),
    );
  }

  Widget _buildCalendarHeader() {
    final monthName = DateFormat('MMMM yyyy', 'fr_FR').format(_currentMonth);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousMonth,
          ),
          Text(
            monthName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstDayOfWeek = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    // Jours de la semaine
    final weekDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

    // Calculer les jours à afficher (inclure les jours du mois précédent/suivant)
    final days = <DateTime>[];
    
    // Ajouter les jours du mois précédent pour compléter la première semaine
    final daysBefore = (firstDayOfWeek - 1) % 7;
    for (int i = daysBefore - 1; i >= 0; i--) {
      days.add(firstDayOfMonth.subtract(Duration(days: i + 1)));
    }
    
    // Ajouter les jours du mois
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month, i));
    }
    
    // Ajouter les jours du mois suivant pour compléter la dernière semaine
    final daysAfter = 42 - days.length; // 6 semaines * 7 jours
    for (int i = 1; i <= daysAfter; i++) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month + 1, i));
    }

    return Column(
      children: [
        // En-tête des jours de la semaine
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            children: weekDays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Grille du calendrier
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final date = days[index];
              final isCurrentMonth = date.month == _currentMonth.month;
              final events = _getEventsForDate(date);
              final hasEvents = events.isNotEmpty;
              final isToday = _isToday(date);
              final isSelected = _isSelected(date);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : isToday
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 2)
                        : isToday
                            ? Border.all(color: AppColors.primary, width: 1)
                            : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isCurrentMonth
                              ? (isSelected || isToday
                                  ? AppColors.primary
                                  : AppColors.textPrimary)
                              : AppColors.textSecondary,
                        ),
                      ),
                      if (hasEvents)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isSelected || isToday
                                ? AppColors.primary
                                : AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedDayEvents() {
    final selectedEvents = _getEventsForDate(_selectedDate);
    final dateFormat = DateFormat('EEEE dd MMMM yyyy', 'fr_FR');

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              dateFormat.format(_selectedDate),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: selectedEvents.isEmpty
                ? Center(
                    child: Text(
                      'Aucun événement ce jour',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: selectedEvents.length,
                    itemBuilder: (context, index) {
                      final event = selectedEvents[index];
                      return _buildEventCard(event);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    final timeFormat = DateFormat('HH:mm');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Icon(
            Icons.event,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.location != null && event.location!.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.location_on, size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.location!,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  timeFormat.format(event.startDate),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(eventId: event.id),
            ),
          );
        },
      ),
    );
  }
}

