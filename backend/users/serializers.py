"""
Serializers for User app.
"""
from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from .models import User, Profile, Friendship, Follow
from core.utils import is_university_email, is_valid_phone, format_phone


class UserRegistrationSerializer(serializers.ModelSerializer):
    """Serializer for user registration."""
    password = serializers.CharField(write_only=True, validators=[validate_password])
    password_confirm = serializers.CharField(write_only=True)
    phone_number = serializers.CharField(required=True)
    
    class Meta:
        model = User
        fields = ['email', 'username', 'password', 'password_confirm', 'first_name', 'last_name', 'role', 'phone_number']
    
    def validate_email(self, value):
        """Validate university email."""
        if not is_university_email(value):
            raise serializers.ValidationError('Email must be from a valid university domain.')
        return value
    
    def validate_phone_number(self, value):
        """Validate and format phone number."""
        formatted = format_phone(value)
        if not is_valid_phone(formatted):
            raise serializers.ValidationError('Phone number must be in format +221XXXXXXXXX.')
        return formatted
    
    def validate(self, attrs):
        """Validate password confirmation."""
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError({'password': 'Passwords do not match.'})
        return attrs
    
    def create(self, validated_data):
        """Create user with hashed password."""
        validated_data.pop('password_confirm')
        password = validated_data.pop('password')
        user = User.objects.create_user(password=password, **validated_data)
        return user


class UserBasicSerializer(serializers.ModelSerializer):
    """Basic user serializer without profile (to avoid circular references)."""
    class Meta:
        model = User
        fields = ['id', 'email', 'username', 'first_name', 'last_name', 'role', 'phone_number', 
                  'phone_verified', 'is_verified', 'verification_status', 'date_joined', 'last_login']
        read_only_fields = ['id', 'date_joined', 'last_login']


class ProfileBasicSerializer(serializers.ModelSerializer):
    """Basic profile serializer without user field (to avoid circular references)."""
    class Meta:
        model = Profile
        fields = ['id', 'university', 'campus', 'field_of_study', 'academic_year', 'bio', 
                  'profile_picture', 'cover_picture', 'date_of_birth', 'interests', 'website',
                  'facebook', 'instagram', 'twitter', 'followers_count', 'following_count', 
                  'friends_count', 'university_email', 'email_verified', 'student_id', 
                  'verification_method', 'reputation_score', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at', 'followers_count', 
                          'following_count', 'friends_count']


class ProfileSerializer(serializers.ModelSerializer):
    """Serializer for user profile with user details."""
    user = UserBasicSerializer(read_only=True)
    
    class Meta:
        model = Profile
        fields = '__all__'
        read_only_fields = ['id', 'user', 'created_at', 'updated_at', 'followers_count', 
                          'following_count', 'friends_count']


class UserSerializer(serializers.ModelSerializer):
    """Serializer for user details with profile."""
    profile = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = ['id', 'email', 'username', 'first_name', 'last_name', 'role', 'phone_number', 
                  'phone_verified', 'is_verified', 'is_active', 'verification_status', 'date_joined', 'last_login', 'profile']
        read_only_fields = ['id', 'date_joined', 'last_login']
    
    def get_profile(self, obj):
        """Get profile data without user field to avoid circular reference."""
        try:
            if hasattr(obj, 'profile') and obj.profile:
                return ProfileBasicSerializer(obj.profile).data
        except Exception:
            pass
        return None


class FriendshipSerializer(serializers.ModelSerializer):
    """Serializer for friendship."""
    from_user = UserBasicSerializer(read_only=True)
    to_user = UserBasicSerializer(read_only=True)
    
    class Meta:
        model = Friendship
        fields = '__all__'
        read_only_fields = ['id', 'from_user', 'created_at', 'updated_at']


class FollowSerializer(serializers.ModelSerializer):
    """Serializer for follow relationship."""
    follower = UserBasicSerializer(read_only=True)
    following = UserBasicSerializer(read_only=True)
    
    class Meta:
        model = Follow
        fields = '__all__'
        read_only_fields = ['id', 'follower', 'created_at']

