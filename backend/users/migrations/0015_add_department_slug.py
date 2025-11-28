# Generated manually to add slug field to Department model

from django.db import migrations, models
from django.utils.text import slugify


def generate_slugs(apps, schema_editor):
    """Generate slugs for existing departments."""
    Department = apps.get_model('users', 'Department')
    for department in Department.objects.all():
        if not department.slug:
            base_slug = slugify(department.name)
            slug = base_slug
            counter = 1
            # Ensure uniqueness within university
            while Department.objects.filter(university=department.university, slug=slug).exclude(id=department.id).exists():
                slug = f"{base_slug}-{counter}"
                counter += 1
            department.slug = slug
            department.save(update_fields=['slug'])


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0014_universitysettings'),
    ]

    operations = [
        migrations.AddField(
            model_name='department',
            name='slug',
            field=models.SlugField(blank=True, db_index=True, help_text='Slug pour les URLs', null=True),
        ),
        migrations.RunPython(generate_slugs, migrations.RunPython.noop),
        migrations.AlterField(
            model_name='department',
            name='slug',
            field=models.SlugField(db_index=True, help_text='Slug pour les URLs'),
        ),
    ]

