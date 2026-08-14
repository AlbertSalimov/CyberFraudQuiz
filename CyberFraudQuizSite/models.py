from django.db import models
from django.core.validators import MinValueValidator


class Question(models.Model):
    header = models.CharField(max_length=100, verbose_name="Заголовок вопроса")
    text = models.CharField(max_length=500, verbose_name="Текст вопроса")
    options = models.JSONField(verbose_name="Варианты ответов")
    score = models.JSONField(verbose_name="Количество баллов")
    explanation = models.JSONField(verbose_name="Объяснение")

    def __str__(self):
        return self.header

    class Meta:
        verbose_name = "Вопрос"
        verbose_name_plural = "Вопросы"


class Result(models.Model):
    session_key = models.CharField(max_length=40, verbose_name="Ключ сессии")
    answers = models.JSONField(verbose_name="Ответы на вопросы")
    score_sum = models.IntegerField(default=0, validators=[MinValueValidator(0)], verbose_name="Сумма баллов")
    completed_at = models.DateTimeField(auto_now_add=True, verbose_name="Дата прохождения")

    def __str__(self):
        return f"{self.session_key} - {self.score_sum}"

    class Meta:
        verbose_name = "Результат"
        verbose_name_plural = "Результаты"
