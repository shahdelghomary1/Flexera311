#!/usr/bin/env python3
"""
Minimal Exercise Counter API Server
Run this script to start the simplified API server for the Flutter app.
"""

if __name__ == "__main__":
    import uvicorn
    print("Starting Exercise Counter API (Minimal Version)...")
    print("API will be available at: http://localhost:8000")
    print("API docs at: http://localhost:8000/docs")
    print("\nEndpoints:")
    print("  POST /count - Send camera frame and get exercise count")
    print("  POST /reset/{user_id}/{exercise_id} - Reset exercise count")
    print("  GET /exercises - List all available exercises")
    print("\nPress Ctrl+C to stop the server")
    
    uvicorn.run(
        "app.main_minimal:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )