from django.shortcuts import render, redirect
from .models import Question, Result


def index(request):
    is_started = False
    if "is_completed" in request.session and not request.session["is_completed"]:
        is_started = True
    if request.method == "POST":
        if not is_started:
            questions = list(Question.objects.all().order_by("id"))
            request.session["questions"] = [q.id for q in questions]
            request.session["current"] = 0
            request.session["total"] = len(questions)
            request.session["answers"] = {}
            request.session["is_explanation"] = False
            request.session["score_sum"] = 0
            request.session["is_completed"] = False
        return redirect("quiz")
    return render(request, "index.html", {
        "is_started": is_started,
    })


def quiz(request):
    if not "questions" in request.session:
        return redirect("index")
    is_completed = request.session["is_completed"]
    if is_completed:
        return redirect("result")
    question_ids = request.session["questions"]
    current_index = request.session["current"]
    total = request.session["total"]
    current_question = Question.objects.get(id=question_ids[current_index])
    is_explanation = request.session["is_explanation"]
    answers = request.session["answers"]
    last_answer = answers.get(str(current_question.id), {
        "answer": 0,
        "score": 0
    })["answer"]
    if request.method == "POST":
        if not is_explanation:
            answer = request.POST.get("answer")
            score = current_question.score[answer]
            answers[str(current_question.id)] = {
                "answer": answer,
                "score": score
            }
            request.session["answers"] = answers
            score_sum = request.session["score_sum"]
            request.session["score_sum"] = score_sum + score
            request.session["is_explanation"] = True
            return redirect("quiz")
        else:
            next_index = current_index + 1
            if next_index == total:
                request.session["is_completed"] = True
                Result.objects.create(
                    session_key=request.session.session_key,
                    answers=request.session["answers"],
                    score_sum=request.session["score_sum"]
                )
                return redirect("result")
            request.session["current"] = next_index
            request.session["is_explanation"] = False
            return redirect("quiz")
    return render(request, "quiz.html", {
        "question": current_question,
        "current": current_index + 1,
        "total": total,
        "is_explanation": is_explanation,
        "last_answer": current_question.options[str(last_answer)],
        "explanation": current_question.explanation[str(last_answer)],
    })


def result(request):
    if not "score_sum" in request.session:
        return redirect("index")
    is_completed = request.session["is_completed"]
    if not is_completed:
        return redirect("quiz")
    score_sum = request.session["score_sum"]
    first_digit = score_sum % 10
    second_digit = score_sum // 10
    score_word = ""
    if second_digit == 1:
        score_word = "баллов"
    else:
        match first_digit:
            case 1:
                score_word = "балл"
            case 2 | 3 | 4:
                score_word = "балла"
            case _:
                score_word = "баллов"
    if request.method == "POST":
        return redirect("index")
    return render(request, "result.html", {
        "score_sum": score_sum,
        "score_word": score_word,
    })


def about(request):
    if request.method == "POST":
        return redirect("index")
    return render(request, "about.html")
