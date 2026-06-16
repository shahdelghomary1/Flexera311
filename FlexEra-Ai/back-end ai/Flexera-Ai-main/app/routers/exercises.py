from typing import List
from fastapi import APIRouter, HTTPException

from app.config import EXERCISE_CATALOG
from app.models.schemas import ExerciseListItem, ExerciseDetailResponse
from app.core.exercise_rules import EXERCISE_INSTRUCTIONS, EXERCISE_CAMERA_CONFIG, ERROR_RULES

router = APIRouter(prefix="/exercises", tags=["Exercises"])


@router.get("", response_model=List[ExerciseListItem], summary="List all exercises")
async def list_exercises():
    return [
        ExerciseListItem(
            id=ex_id,
            name=info["name"],
            key=info["key"],
            category=info["category"],
            session=info["session"],
            image=info["image"],
        )
        for ex_id, info in EXERCISE_CATALOG.items()
    ]


@router.get("/category/{category}", response_model=List[ExerciseListItem], summary="Get exercises by category")
async def get_exercises_by_category(category: str):
    category_map = {
        "knee": ["lower_left", "lower_right"],
        "shoulder": ["upper_left", "upper_right"],
    }
    target_categories = category_map.get(category, [category])

    results = [
        ExerciseListItem(
            id=ex_id,
            name=info["name"],
            key=info["key"],
            category=info["category"],
            session=info["session"],
            image=info["image"],
        )
        for ex_id, info in EXERCISE_CATALOG.items()
        if info["category"] in target_categories
    ]

    if not results:
        raise HTTPException(status_code=404, detail=f"No exercises found for category: {category}")
    return results


@router.get("/{exercise_id}", response_model=ExerciseDetailResponse, summary="Get exercise detail")
async def get_exercise_detail(exercise_id: str):
    info = EXERCISE_CATALOG.get(exercise_id)
    if not info:
        raise HTTPException(status_code=404, detail=f"Exercise {exercise_id} not found")

    key = info["key"]
    raw_rules = ERROR_RULES.get(key, {})
    safe_rules: dict = {}
    for k, v in raw_rules.items():
        if k == "errors":
            safe_rules["errors"] = {
                err_name: {
                    "recommendation": err_data["recommendation"],
                    "severity": err_data["severity"],
                }
                for err_name, err_data in v.items()
            }
        elif not callable(v):
            safe_rules[k] = v

    return ExerciseDetailResponse(
        id=exercise_id,
        name=info["name"],
        key=key,
        category=info["category"],
        session=info["session"],
        image=info["image"],
        instructions=EXERCISE_INSTRUCTIONS.get(key, {}),
        camera_config=EXERCISE_CAMERA_CONFIG.get(key, {}),
        rules=safe_rules,
    )
