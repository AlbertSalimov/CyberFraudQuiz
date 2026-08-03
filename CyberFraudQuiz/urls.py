from django.contrib import admin
from django.urls import path
from CyberFraudQuizSite import views

urlpatterns = [
    path('admin/', admin.site.urls),
    path("", views.index, name="index"),
    path("quiz", views.quiz, name="quiz"),
    path("about", views.about, name="about"),
    path("result", views.result, name="result"),
]
