"""
Serializers for User app.
"""
from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from .models import User, Profile, Friendship, Follow, University, Campus, Department
from django.db import models
from core.utils import is_university_email, is_valid_phone, format_phone, get_university_from_email


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    """
    Custom token serializer that accepts 'email' instead of 'username'.
    This allows login with email while maintaining JWT compatibility.
    """
    email = serializers.EmailField(required=True)
    password = serializers.CharField(required=True, write_only=True)
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Remove username field since we're using email
        self.fields.pop('username', None)
    
    @classmethod
    def get_token(cls, user):
        """
        Generate token for user.
        """
        from rest_framework_simplejwt.tokens import RefreshToken
        return RefreshToken.for_user(user)
    
    def validate(self, attrs):
        """
        Validate email and password, then return the user and tokens.
        """
        email = attrs.get('email')
        password = attrs.get('password')
        
        if not email or not password:
            raise serializers.ValidationError('Email and password are required.')
        
        # Get user by email
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            raise serializers.ValidationError('No active account found with the given credentials.')
        
        # Check password
        if not user.check_password(password):
            raise serializers.ValidationError('No active account found with the given credentials.')
        
        # Check if user is banned
        if user.is_banned:
            raise serializers.ValidationError('Your account has been banned.')
        
        # Generate tokens using the parent class method
        refresh = self.get_token(user)
        
        # Return token data
        return {
            'refresh': str(refresh),
            'access': str(refresh.access_token),
            'user_id': str(user.id),
            'email': user.email,
            'username': user.username,
            'role': user.role,
        }


class UniversitySettingsSerializer(serializers.ModelSerializer):
    """Serializer for UniversitySettings model."""
    class Meta:
        from .models import UniversitySettings
        model = UniversitySettings
        fields = '__all__'
        read_only_fields = ['id', 'created_at', 'updated_at']


class UniversitySerializer(serializers.ModelSerializer):
    """Serializer for University model."""
    students_count = serializers.SerializerMethodField()
    groups_count = serializers.SerializerMethodField()
    admin = serializers.SerializerMethodField()
    settings = serializers.SerializerMethodField()
    
    class Meta:
        model = University
        fields = [
            'id', 'name', 'slug', 'short_name', 'email_domains', 'logo', 'cover_image',
            'description', 'website', 'address', 'phone', 'is_active', 'created_at',
            'updated_at', 'students_count', 'groups_count', 'admin', 'settings'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at', 'students_count', 'groups_count', 'admin', 'settings']
    
    def to_representation(self, instance):
        """Ensure proper UTF-8 encoding for all string fields."""
        data = super().to_representation(instance)
        
        # Fix encoding for string fields
        string_fields = ['name', 'short_name', 'description', 'address', 'phone']
        for field in string_fields:
            if field in data and data[field]:
                try:
                    # If it's already a string, ensure it's properly decoded
                    if isinstance(data[field], str):
                        # Try to fix common encoding issues
                        # If the string appears to be double-encoded, fix it
                        if 'Ã' in data[field] or 'Â' in data[field]:
                            # Try to fix double-encoded UTF-8
                            try:
                                # Decode as latin1 then encode as utf8 then decode as utf8
                                fixed = data[field].encode('latin1').decode('utf-8')
                                data[field] = fixed
                            except (UnicodeDecodeError, UnicodeEncodeError):
                                # If that fails, use character replacement method
                                replacements = {
                                    'Ã‰': 'É', 'Ã©': 'é', 'Ã¨': 'è', 'Ã§': 'ç',
                                    'Ã ': 'à', 'Ã´': 'ô', 'Ã®': 'î', 'Ã»': 'û',
                                    'Ã¯': 'ï', 'Ã«': 'ë', 'Ãª': 'ê', 'Ã¢': 'â',
                                    'Ã¹': 'ù', 'Ã': 'À', 'Â': '',
                                }
                                fixed = data[field]
                                for old, new in replacements.items():
                                    fixed = fixed.replace(old, new)
                                data[field] = fixed
                        # Ensure the final string is valid UTF-8
                        data[field] = data[field].encode('utf-8', errors='ignore').decode('utf-8')
                except (UnicodeDecodeError, UnicodeEncodeError, AttributeError):
                    # If encoding fails, keep original value
                    pass
        
        return data
    
    def get_students_count(self, obj):
        """Get count of active students in this university."""
        try:
            from users.models import Profile
            return Profile.objects.filter(
                university=obj,
                user__is_active=True,
                user__role='student'
            ).count()
        except Exception:
            return 0
    
    def get_groups_count(self, obj):
        """Get count of active groups in this university."""
        try:
            from groups.models import Group
            return Group.objects.filter(
                university=obj,
                is_public=True
            ).count()
        except Exception:
            return 0
    
    def get_admin(self, obj):
        """Get university admin information."""
        try:
            admin = obj.get_admin()
            if admin:
                return {
                    'id': str(admin.id),
                    'username': admin.username,
                    'email': admin.email,
                    'first_name': admin.first_name,
                    'last_name': admin.last_name,
                }
        except Exception:
            pass
        return None
    
    def get_settings(self, obj):
        """Get university settings."""
        try:
            from .models import UniversitySettings
            settings = UniversitySettings.objects.filter(university=obj).first()
            if settings:
                return UniversitySettingsSerializer(settings).data
        except Exception:
            pass
        return None


class UniversityBasicSerializer(serializers.ModelSerializer):
    """Basic serializer for University (without counts)."""
    class Meta:
        model = University
        fields = ['id', 'name', 'slug', 'short_name', 'logo']
        read_only_fields = ['id']
    
    def to_representation(self, instance):
        """Safely serialize university data with proper UTF-8 encoding."""
        try:
            data = super().to_representation(instance)
            # Fix encoding for name and short_name
            for field in ['name', 'short_name']:
                if field in data and data[field]:
                    if isinstance(data[field], str) and ('Ã' in data[field] or 'Â' in data[field]):
                        try:
                            fixed = data[field].encode('latin1').decode('utf-8')
                            data[field] = fixed
                        except (UnicodeDecodeError, UnicodeEncodeError):
                            # Use character replacement as fallback
                            replacements = {
                                'Ã‰': 'É', 'Ã©': 'é', 'Ã¨': 'è', 'Ã§': 'ç',
                                'Ã ': 'à', 'Ã´': 'ô', 'Ã®': 'î', 'Ã»': 'û',
                                'Ã¯': 'ï', 'Ã«': 'ë', 'Ãª': 'ê', 'Ã¢': 'â',
                                'Ã¹': 'ù', 'Ã': 'À', 'Â': '',
                            }
                            fixed = data[field]
                            for old, new in replacements.items():
                                fixed = fixed.replace(old, new)
                            data[field] = fixed
            return data
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.warning(f"Error serializing university {instance.id if instance else 'None'}: {e}")
            # Return minimal safe data
            return {
                'id': str(instance.id) if instance and hasattr(instance, 'id') else None,
                'name': str(instance.name) if instance and hasattr(instance, 'name') else '',
                'slug': str(instance.slug) if instance and hasattr(instance, 'slug') else '',
                'short_name': str(instance.short_name) if instance and hasattr(instance, 'short_name') else '',
                'logo': None
            }


class CampusSerializer(serializers.ModelSerializer):
    """Serializer for Campus model."""
    university = UniversityBasicSerializer(read_only=True)
    university_id = serializers.UUIDField(write_only=True, required=False)
    students_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Campus
        fields = [
            'id', 'university', 'university_id', 'name', 'slug', 'address', 'city', 'country',
            'phone', 'email', 'is_main', 'is_active', 'latitude', 'longitude',
            'created_at', 'updated_at', 'students_count'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at', 'students_count']
    
    def create(self, validated_data):
        """Create campus with university handling."""
        university_id = validated_data.pop('university_id', None)
        if university_id:
            from .models import University
            try:
                validated_data['university'] = University.objects.get(id=university_id)
            except University.DoesNotExist:
                raise serializers.ValidationError({'university_id': 'Université introuvable.'})
        return super().create(validated_data)
    
    def get_students_count(self, obj):
        """Get count of active students in this campus."""
        return obj.students.filter(user__is_active=True, user__role='student').count()


class CampusBasicSerializer(serializers.ModelSerializer):
    """Basic serializer for Campus (without counts)."""
    class Meta:
        model = Campus
        fields = ['id', 'name', 'slug', 'city', 'is_main']
        read_only_fields = ['id']


class DepartmentSerializer(serializers.ModelSerializer):
    """Serializer for Department model."""
    university = UniversityBasicSerializer(read_only=True)
    university_id = serializers.UUIDField(write_only=True, required=False)
    students_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Department
        fields = [
            'id', 'university', 'university_id', 'name', 'slug', 'code', 'description',
            'is_active', 'created_at', 'updated_at', 'students_count'
        ]
        read_only_fields = ['id', 'slug', 'created_at', 'updated_at', 'students_count']
    
    def create(self, validated_data):
        """Create department with university handling."""
        university_id = validated_data.pop('university_id', None)
        if university_id:
            from .models import University
            try:
                validated_data['university'] = University.objects.get(id=university_id)
            except University.DoesNotExist:
                raise serializers.ValidationError({'university_id': 'Université introuvable.'})
        # Slug will be auto-generated in model.save()
        return super().create(validated_data)
    
    def get_students_count(self, obj):
        """Get count of active students in this department."""
        return obj.students.filter(user__is_active=True, user__role='student').count()


class DepartmentBasicSerializer(serializers.ModelSerializer):
    """Basic serializer for Department (without counts)."""
    class Meta:
        model = Department
        fields = ['id', 'name', 'code', 'slug']
        read_only_fields = ['id', 'slug']


class UserRegistrationSerializer(serializers.ModelSerializer):
    """Serializer for user registration."""
    password = serializers.CharField(write_only=True, validators=[validate_password])
    password_confirm = serializers.CharField(write_only=True)
    phone_number = serializers.CharField(required=True)
    academic_year = serializers.CharField(required=True, max_length=50, help_text="Classe de l'étudiant (Licence 1, Licence 2, Licence 3, Master 1, Master 2)")
    
    class Meta:
        model = User
        fields = ['email', 'username', 'password', 'password_confirm', 'first_name', 'last_name', 'role', 'phone_number', 'academic_year']
    
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
        """Create user with hashed password and auto-assign university based on email."""
        validated_data.pop('password_confirm')
        password = validated_data.pop('password')
        academic_year = validated_data.pop('academic_year', None)
        email = validated_data.get('email', '')
        
        # Force role to 'student' for registration
        validated_data['role'] = 'student'
        
        user = User.objects.create_user(password=password, **validated_data)
        
        # Auto-assign university based on email domain and set academic_year
        if email and '@' in email:
            try:
                university = get_university_from_email(email)
                if university and hasattr(user, 'profile') and user.profile:
                    user.profile.university = university
                    if academic_year:
                        user.profile.academic_year = academic_year
                    user.profile.save(update_fields=['university', 'academic_year'])
            except Exception as e:
                # If university not found, leave it null but still set academic_year
                import logging
                logger = logging.getLogger(__name__)
                logger.warning(f"Could not assign university for email {email}: {e}")
                if academic_year and hasattr(user, 'profile') and user.profile:
                    user.profile.academic_year = academic_year
                    user.profile.save(update_fields=['academic_year'])
        
        return user


class UserBasicSerializer(serializers.ModelSerializer):
    """Basic user serializer without profile (to avoid circular references)."""
    class Meta:
        model = User
        fields = ['id', 'email', 'username', 'first_name', 'last_name', 'role', 'phone_number', 
                  'phone_verified', 'is_verified', 'is_staff', 'is_superuser', 'verification_status', 'date_joined', 'last_login']
        read_only_fields = ['id', 'date_joined', 'last_login', 'is_staff', 'is_superuser']


class ProfileBasicSerializer(serializers.ModelSerializer):
    """Basic profile serializer without user field (to avoid circular references)."""
    university = UniversityBasicSerializer(read_only=True)
    university_id = serializers.UUIDField(write_only=True, required=False, allow_null=True)
    campus = CampusBasicSerializer(read_only=True)
    campus_id = serializers.UUIDField(write_only=True, required=False, allow_null=True)
    department = DepartmentBasicSerializer(read_only=True)
    department_id = serializers.UUIDField(write_only=True, required=False, allow_null=True)
    friends_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Profile
        fields = ['id', 'university', 'university_id', 'campus', 'campus_id', 'department', 'department_id', 'field_of_study', 'academic_year', 'bio', 
                  'profile_picture', 'cover_picture', 'date_of_birth', 'interests', 'website',
                  'facebook', 'instagram', 'twitter', 'followers_count', 'following_count', 
                  'friends_count', 'university_email', 'email_verified', 'student_id', 
                  'verification_method', 'reputation_score', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at', 'followers_count', 
                          'following_count', 'friends_count']
    
    def get_friends_count(self, obj):
        """Calculate friends count dynamically from Friendship model."""
        try:
            from .models import Friendship
            from django.db.models import Q
            user = obj.user
            if user:
                count = Friendship.objects.filter(
                    (Q(from_user=user) | Q(to_user=user)),
                    status='accepted'
                ).count()
                return count
        except Exception:
            pass
        # Fallback to stored value if calculation fails
        return obj.friends_count or 0
    
    def update(self, instance, validated_data):
        """Update profile with university_id, campus_id and department_id handling."""
        university_id = validated_data.pop('university_id', None)
        campus_id = validated_data.pop('campus_id', None)
        department_id = validated_data.pop('department_id', None)
        
        if university_id is not None:
            try:
                instance.university = University.objects.get(id=university_id)
            except University.DoesNotExist:
                instance.university = None
        
        if campus_id is not None:
            try:
                campus = Campus.objects.get(id=campus_id)
                if instance.university and campus.university != instance.university:
                    raise serializers.ValidationError('Le campus doit appartenir à l\'université sélectionnée.')
                instance.campus = campus
            except Campus.DoesNotExist:
                instance.campus = None
        elif university_id is not None and instance.university:
            if instance.campus and instance.campus.university != instance.university:
                instance.campus = None
        
        if department_id is not None:
            try:
                department = Department.objects.get(id=department_id)
                if instance.university and department.university != instance.university:
                    raise serializers.ValidationError('Le département doit appartenir à l\'université sélectionnée.')
                instance.department = department
            except Department.DoesNotExist:
                instance.department = None
        elif university_id is not None and instance.university:
            if instance.department and instance.department.university != instance.university:
                instance.department = None
        
        return super().update(instance, validated_data)


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
                  'phone_verified', 'is_verified', 'is_active', 'is_staff', 'is_superuser', 'verification_status', 'date_joined', 'last_login', 'profile']
        read_only_fields = ['id', 'date_joined', 'last_login', 'is_staff', 'is_superuser']
    
    def get_profile(self, obj):
        """Get profile data without user field to avoid circular reference."""
        try:
            if hasattr(obj, 'profile') and obj.profile:
                # Pass context if available
                context = self.context if hasattr(self, 'context') else {}
                return ProfileBasicSerializer(obj.profile, context=context).data
        except Exception as e:
            # Log the error for debugging
            import logging
            logger = logging.getLogger(__name__)
            logger.warning(f"Error serializing profile for user {obj.id}: {e}")
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

