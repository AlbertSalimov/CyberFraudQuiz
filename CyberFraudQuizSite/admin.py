from django.contrib import admin
from .models import Question, Result


@admin.register(Question)
class QuestionAdmin(admin.ModelAdmin):
    list_display = ('header', 'text')


@admin.register(Result)
class ResultAdmin(admin.ModelAdmin):
    list_display = ('session_key', 'score_sum', 'completed_at')
