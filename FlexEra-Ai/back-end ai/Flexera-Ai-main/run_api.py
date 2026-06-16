#!/usr/bin/env python3
"""
Exercise Counter API Server
Dedicated API server with all endpoints organized in one file
"""

import sys
import os

# Add the project root to Python path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

if __name__ == "__main__":
    import uvicorn
    
    print("=" * 50)
    print("🚀 Exercise Counter API Server")
    print("=" * 50)
    print("📱 API Documentation: http://localhost:8000/docs")
    print("🔍 Health Check:     http://localhost:8000/health") 
    print("📋 Exercise List:    http://localhost:8000/exercises")
    print("🎯 Main Endpoint:    POST http://localhost:8000/count")
    print("🔄 Reset Endpoint:   POST http://localhost:8000/reset/{user}/{exercise}")
    print("-" * 50)
    print("📖 Available Endpoints:")
    print("  • POST /count - Process camera frame and get count")
    print("  • POST /reset/{user_id}/{exercise_id} - Reset count")
    print("  • GET /exercises - List all 16 exercises")
    print("  • GET /health - API health status")
    print("  • GET /sessions - List active sessions")
    print("-" * 50)
    print("⚡ Starting server on port 8000...")
    print("⚠️  Press Ctrl+C to stop")
    print("=" * 50)
    
    try:
        uvicorn.run(
            "app.api.exercise_api:app",
            host="0.0.0.0",
            port=8000,
            reload=True,
            log_level="info"
        )
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user")
    except Exception as e:
        print(f"\n❌ Server error: {e}")
        sys.exit(1)