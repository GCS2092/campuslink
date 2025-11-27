"""
Script de test pour insérer des données dans toutes les tables.
Vérifie que toutes les sauvegardes fonctionnent correctement.
"""
import os
import django
from django.utils import timezone
from datetime import timedelta

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'campuslink.settings')
django.setup()

from users.models import User, Profile, Friendship, Follow
from events.models import Category, Event, Participation, EventComment, EventLike, EventFavorite
from social.models import Post, PostComment, PostLike
from payments.models import Payment, Ticket
from notifications.models import Notification
from moderation.models import Report, AuditLog


def test_all_tables():
    """Test l'insertion de données dans toutes les tables."""
    print("=" * 60)
    print("TEST D'INSERTION DANS TOUTES LES TABLES")
    print("=" * 60)
    
    # Nettoyer les données de test existantes (optionnel)
    print("\n1. Nettoyage des données de test existantes...")
    User.objects.filter(email__startswith='test_').delete()
    print("   ✓ Données de test nettoyées")
    
    # ========== USERS ==========
    print("\n2. Test table User...")
    try:
        user1 = User.objects.create_user(
            email='test_user1@esmt.sn',
            username='testuser1',
            password='Test123!',
            phone_number='+221771234567',
            first_name='Test',
            last_name='User1',
            role='student',
            is_verified=True,
            verification_status='verified',
            phone_verified=True
        )
        print(f"   ✓ User créé : {user1.username} (ID: {user1.id})")
        
        user2 = User.objects.create_user(
            email='test_user2@ucad.sn',
            username='testuser2',
            password='Test123!',
            phone_number='+221771234568',
            first_name='Test',
            last_name='User2',
            role='student',
            is_verified=True,
            verification_status='verified',
            phone_verified=True
        )
        print(f"   ✓ User créé : {user2.username} (ID: {user2.id})")
    except Exception as e:
        print(f"   ✗ Erreur User : {e}")
        return False
    
    # ========== PROFILE ==========
    print("\n3. Test table Profile...")
    try:
        profile1 = user1.profile
        profile1.university = 'ESMT'
        profile1.campus = 'Dakar'
        profile1.field_of_study = 'Informatique'
        profile1.academic_year = 'L3'
        profile1.bio = 'Étudiant en informatique passionné par les événements'
        profile1.interests = ['Technologie', 'Sport', 'Musique']
        profile1.university_email = 'test_user1@esmt.sn'
        profile1.email_verified = True
        # Test du chiffrement du matricule
        profile1.student_id = profile1.encrypt_student_id('ESMT2024001')
        profile1.save()
        print(f"   ✓ Profile créé pour {user1.username}")
        print(f"     - Matricule chiffré : {profile1.student_id[:50]}...")
        print(f"     - Matricule déchiffré : {profile1.decrypt_student_id()}")
        
        profile2 = user2.profile
        profile2.university = 'UCAD'
        profile2.campus = 'Dakar'
        profile2.field_of_study = 'Économie'
        profile2.academic_year = 'M1'
        profile2.save()
        print(f"   ✓ Profile créé pour {user2.username}")
    except Exception as e:
        print(f"   ✗ Erreur Profile : {e}")
        return False
    
    # ========== FRIENDSHIP ==========
    print("\n4. Test table Friendship...")
    try:
        friendship = Friendship.objects.create(
            from_user=user1,
            to_user=user2,
            status='accepted'
        )
        print(f"   ✓ Friendship créée : {user1.username} -> {user2.username}")
    except Exception as e:
        print(f"   ✗ Erreur Friendship : {e}")
        return False
    
    # ========== FOLLOW ==========
    print("\n5. Test table Follow...")
    try:
        follow = Follow.objects.create(
            follower=user1,
            following=user2
        )
        print(f"   ✓ Follow créé : {user1.username} suit {user2.username}")
    except Exception as e:
        print(f"   ✗ Erreur Follow : {e}")
        return False
    
    # ========== CATEGORY ==========
    print("\n6. Test table Category...")
    try:
        category, created = Category.objects.get_or_create(
            name='Concert',
            defaults={
                'slug': 'concert',
                'description': 'Événements musicaux et concerts',
                'icon': 'music'
            }
        )
        if created:
            print(f"   ✓ Category créée : {category.name}")
        else:
            print(f"   ✓ Category existante réutilisée : {category.name}")
    except Exception as e:
        print(f"   ✗ Erreur Category : {e}")
        return False
    
    # ========== EVENT ==========
    print("\n7. Test table Event...")
    try:
        event = Event.objects.create(
            title='Concert de Musique Africaine',
            description='Un magnifique concert de musique africaine avec plusieurs artistes',
            organizer=user1,
            category=category,
            start_date=timezone.now() + timedelta(days=7),
            end_date=timezone.now() + timedelta(days=7, hours=3),
            location='Place de l\'Indépendance, Dakar',
            location_lat=14.7167,
            location_lng=-17.4677,
            price=5000.00,
            is_free=False,
            capacity=500,
            status='published',
            is_featured=True
        )
        print(f"   ✓ Event créé : {event.title} (ID: {event.id})")
    except Exception as e:
        print(f"   ✗ Erreur Event : {e}")
        return False
    
    # ========== PARTICIPATION ==========
    print("\n8. Test table Participation...")
    try:
        participation = Participation.objects.create(
            user=user2,
            event=event
        )
        event.participants_count = 1
        event.save()
        print(f"   ✓ Participation créée : {user2.username} participe à {event.title}")
    except Exception as e:
        print(f"   ✗ Erreur Participation : {e}")
        return False
    
    # ========== EVENTCOMMENT ==========
    print("\n9. Test table EventComment...")
    try:
        comment = EventComment.objects.create(
            event=event,
            user=user2,
            content='Super événement ! J\'ai hâte d\'y être !'
        )
        print(f"   ✓ EventComment créé : {user2.username} a commenté {event.title}")
    except Exception as e:
        print(f"   ✗ Erreur EventComment : {e}")
        return False
    
    # ========== EVENTLIKE ==========
    print("\n10. Test table EventLike...")
    try:
        like = EventLike.objects.create(
            event=event,
            user=user2
        )
        event.likes_count = 1
        event.save()
        print(f"   ✓ EventLike créé : {user2.username} a liké {event.title}")
    except Exception as e:
        print(f"   ✗ Erreur EventLike : {e}")
        return False
    
    # ========== EVENTFAVORITE ==========
    print("\n11. Test table EventFavorite...")
    try:
        favorite = EventFavorite.objects.create(
            user=user2,
            event=event
        )
        print(f"   ✓ EventFavorite créé : {user2.username} a favorisé {event.title}")
    except Exception as e:
        print(f"   ✗ Erreur EventFavorite : {e}")
        return False
    
    # ========== POST ==========
    print("\n12. Test table Post...")
    try:
        post = Post.objects.create(
            author=user1,
            content='Bonjour à tous ! Nouveau sur CampusLink, ravi de vous rencontrer !',
            post_type='text',
            is_public=True
        )
        print(f"   ✓ Post créé : {user1.username} a publié un post (ID: {post.id})")
    except Exception as e:
        print(f"   ✗ Erreur Post : {e}")
        return False
    
    # ========== POSTCOMMENT ==========
    print("\n13. Test table PostComment...")
    try:
        post_comment = PostComment.objects.create(
            post=post,
            user=user2,
            content='Bienvenue !'
        )
        post.comments_count = 1
        post.save()
        print(f"   ✓ PostComment créé : {user2.username} a commenté le post")
    except Exception as e:
        print(f"   ✗ Erreur PostComment : {e}")
        return False
    
    # ========== POSTLIKE ==========
    print("\n14. Test table PostLike...")
    try:
        post_like = PostLike.objects.create(
            post=post,
            user=user2
        )
        post.likes_count = 1
        post.save()
        print(f"   ✓ PostLike créé : {user2.username} a liké le post")
    except Exception as e:
        print(f"   ✗ Erreur PostLike : {e}")
        return False
    
    # ========== PAYMENT ==========
    print("\n15. Test table Payment...")
    try:
        payment = Payment.objects.create(
            user=user2,
            event=event,
            amount=5000.00,
            commission=250.00,  # 5%
            net_amount=4750.00,
            payment_method='stripe',
            status='completed'
        )
        payment.completed_at = timezone.now()
        payment.save()
        print(f"   ✓ Payment créé : {payment.transaction_id} - {payment.amount} FCFA")
    except Exception as e:
        print(f"   ✗ Erreur Payment : {e}")
        return False
    
    # ========== TICKET ==========
    print("\n16. Test table Ticket...")
    try:
        ticket = Ticket.objects.create(
            payment=payment,
            user=user2,
            event=event
        )
        print(f"   ✓ Ticket créé : {ticket.ticket_code}")
    except Exception as e:
        print(f"   ✗ Erreur Ticket : {e}")
        return False
    
    # ========== NOTIFICATION ==========
    print("\n17. Test table Notification...")
    try:
        notification = Notification.objects.create(
            recipient=user2,
            notification_type='event_reminder',
            title='Rappel d\'événement',
            message=f'L\'événement "{event.title}" commence dans 24h !',
            is_read=False,
            related_object_type='event',
            related_object_id=event.id
        )
        print(f"   ✓ Notification créée : {notification.title}")
    except Exception as e:
        print(f"   ✗ Erreur Notification : {e}")
        import traceback
        traceback.print_exc()
        return False
    
    # ========== REPORT ==========
    print("\n18. Test table Report...")
    try:
        report = Report.objects.create(
            reporter=user2,
            content_type='post',
            content_id=post.id,
            reason='spam',
            description='Ce post semble être du spam',
            status='pending'
        )
        print(f"   ✓ Report créé : Signalement de {report.content_type}")
    except Exception as e:
        print(f"   ✗ Erreur Report : {e}")
        return False
    
    # ========== AUDITLOG ==========
    print("\n19. Test table AuditLog...")
    try:
        audit_log = AuditLog.objects.create(
            user=user1,
            action_type='CREATE',
            resource_type='event',
            resource_id=event.id,
            ip_address='127.0.0.1',
            user_agent='Mozilla/5.0',
            details={'action': 'created_event', 'event_title': event.title}
        )
        print(f"   ✓ AuditLog créé : {audit_log.action_type} {audit_log.resource_type}")
    except Exception as e:
        print(f"   ✗ Erreur AuditLog : {e}")
        return False
    
    # ========== VÉRIFICATION FINALE ==========
    print("\n" + "=" * 60)
    print("VÉRIFICATION DES DONNÉES SAUVEGARDÉES")
    print("=" * 60)
    
    counts = {
        'Users': User.objects.filter(email__startswith='test_').count(),
        'Profiles': Profile.objects.filter(user__email__startswith='test_').count(),
        'Friendships': Friendship.objects.filter(from_user__email__startswith='test_').count(),
        'Follows': Follow.objects.filter(follower__email__startswith='test_').count(),
        'Categories': Category.objects.count(),
        'Events': Event.objects.filter(organizer__email__startswith='test_').count(),
        'Participations': Participation.objects.filter(user__email__startswith='test_').count(),
        'EventComments': EventComment.objects.filter(user__email__startswith='test_').count(),
        'EventLikes': EventLike.objects.filter(user__email__startswith='test_').count(),
        'EventFavorites': EventFavorite.objects.filter(user__email__startswith='test_').count(),
        'Posts': Post.objects.filter(author__email__startswith='test_').count(),
        'PostComments': PostComment.objects.filter(user__email__startswith='test_').count(),
        'PostLikes': PostLike.objects.filter(user__email__startswith='test_').count(),
        'Payments': Payment.objects.filter(user__email__startswith='test_').count(),
        'Tickets': Ticket.objects.filter(user__email__startswith='test_').count(),
        'Notifications': Notification.objects.filter(recipient__email__startswith='test_').count(),
        'Reports': Report.objects.filter(reporter__email__startswith='test_').count(),
        'AuditLogs': AuditLog.objects.filter(user__email__startswith='test_').count(),
    }
    
    print("\nRésumé des données sauvegardées :")
    for table, count in counts.items():
        status = "✓" if count > 0 else "✗"
        print(f"   {status} {table}: {count} enregistrement(s)")
    
    print("\n" + "=" * 60)
    print("✅ TOUS LES TESTS SONT TERMINÉS !")
    print("=" * 60)
    print("\nVous pouvez maintenant vérifier dans l'admin Django :")
    print("   - Users : test_user1@esmt.sn, test_user2@ucad.sn")
    print("   - Events : 'Concert de Musique Africaine'")
    print("   - Payments : Transaction avec commission")
    print("   - Tickets : Code de billet généré")
    print("   - Et toutes les autres tables...")
    print("\nAccès admin : http://localhost:8000/admin/")
    
    return True


if __name__ == '__main__':
    try:
        success = test_all_tables()
        if success:
            print("\n✅ SUCCÈS : Toutes les données ont été sauvegardées !")
        else:
            print("\n❌ ÉCHEC : Certaines données n'ont pas pu être sauvegardées.")
    except Exception as e:
        print(f"\n❌ ERREUR CRITIQUE : {e}")
        import traceback
        traceback.print_exc()

