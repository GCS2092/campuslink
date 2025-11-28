"""
URLs for User app.
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (
    register, verify_phone, resend_otp, verify_email, verification_status, profile,
    CustomTokenObtainPairView, UserViewSet, UniversityViewSet, CampusViewSet, friends_list, send_friend_request,
    accept_friend_request, reject_friend_request, remove_friend, friend_requests,
    friendship_status, pending_students, activate_student, deactivate_student,
    admin_dashboard_stats, class_leader_dashboard_stats, university_admin_dashboard_stats, class_leaders_list, assign_class_leader, revoke_class_leader,
    class_leaders_by_university
)
from .admin_views import (
    verify_user, reject_user, ban_user, unban_user,
    get_pending_verifications, get_banned_users, create_student
)

router = DefaultRouter()
router.register(r'', UserViewSet, basename='user')
router.register(r'universities', UniversityViewSet, basename='university')
router.register(r'campuses', CampusViewSet, basename='campus')
# DepartmentViewSet removed as per user request

urlpatterns = [
    # Authentication
    path('register/', register, name='register'),
    path('login/', CustomTokenObtainPairView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    
    # Verification
    path('verify-phone/', resend_otp, name='resend_otp'),
    path('verify-phone/confirm/', verify_phone, name='verify_phone_confirm'),
    path('verify-email/<str:token>/', verify_email, name='verify_email'),
    path('verification-status/', verification_status, name='verification_status'),
    
    # Profile
    path('profile/', profile, name='profile'),
    
    # Friends
    path('friends/', friends_list, name='friends_list'),
    path('friends/request/', send_friend_request, name='send_friend_request'),
    path('friends/requests/', friend_requests, name='friend_requests'),
    path('friends/<uuid:friendship_id>/accept/', accept_friend_request, name='accept_friend_request'),
    path('friends/<uuid:friendship_id>/reject/', reject_friend_request, name='reject_friend_request'),
    path('friends/<uuid:friendship_id>/', remove_friend, name='remove_friend'),
    path('friends/status/<uuid:user_id>/', friendship_status, name='friendship_status'),
    
    # Admin/Class Leader endpoints
    path('admin/pending-students/', pending_students, name='pending_students'),
    path('admin/students/<uuid:user_id>/activate/', activate_student, name='activate_student'),
    path('admin/students/<uuid:user_id>/deactivate/', deactivate_student, name='deactivate_student'),
    path('admin/dashboard-stats/', admin_dashboard_stats, name='admin_dashboard_stats'),
    
    # Class Leader dashboard (separate from admin)
    path('class-leader/dashboard-stats/', class_leader_dashboard_stats, name='class_leader_dashboard_stats'),
    
    # University Admin dashboard
    path('university-admin/dashboard-stats/', university_admin_dashboard_stats, name='university_admin_dashboard_stats'),
    
    # University Admin - Create student
    path('university-admin/students/create/', create_student, name='university_admin_create_student'),
    
    # Class Leaders management (admin only)
    path('admin/class-leaders/', class_leaders_list, name='class_leaders_list'),
    path('admin/class-leaders/by-university/', class_leaders_by_university, name='class_leaders_by_university'),
    path('admin/class-leaders/<uuid:user_id>/assign/', assign_class_leader, name='assign_class_leader'),
    path('admin/class-leaders/<uuid:user_id>/revoke/', revoke_class_leader, name='revoke_class_leader'),
    
    # User verification and banning
    path('admin/users/<uuid:user_id>/verify/', verify_user, name='verify_user'),
    path('admin/users/<uuid:user_id>/reject/', reject_user, name='reject_user'),
    path('admin/users/<uuid:user_id>/ban/', ban_user, name='ban_user'),
    path('admin/users/<uuid:user_id>/unban/', unban_user, name='unban_user'),
    path('admin/users/pending-verifications/', get_pending_verifications, name='get_pending_verifications'),
    path('admin/users/banned/', get_banned_users, name='get_banned_users'),
    
    # Users
    path('', include(router.urls)),
]

