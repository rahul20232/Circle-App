from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import httpx
import os
import logging

router = APIRouter(
    prefix="/gemini",
    tags=["Gemini"]
)

class GenerateTextRequest(BaseModel):
    prompt: str

class GenerateTextResponse(BaseModel):
    output_text: str

@router.post("/generate-text", response_model=GenerateTextResponse)
async def generate_text(request: GenerateTextRequest):
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="GEMINI_API_KEY not set")

    url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
    headers = {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": api_key
    }
    payload = {"contents": [{"parts": [{"text": request.prompt}]}]}

    async with httpx.AsyncClient(timeout=15.0) as client:
        response = await client.post(url, headers=headers, json=payload)

    # LOG the full response text
    logging.info(f"Response status: {response.status_code}")
    logging.info(f"Response body: {response.text}")

    if response.status_code != 200:
        logging.error(f"Gemini API error: {response.status_code} - {response.text}")
        raise HTTPException(status_code=response.status_code, detail=f"Gemini API error: {response.text}")

    try:
        data = response.json()
    except Exception as e:
        logging.error(f"Failed to parse JSON: {e}, response text: {response.text}")
        raise HTTPException(status_code=500, detail=f"Failed to parse response: {response.text}")

    # Better error handling for the response structure
    try:
        candidates = data.get("candidates", [])
        if not candidates:
            logging.error(f"No candidates in response: {data}")
            raise HTTPException(status_code=500, detail="No candidates returned from Gemini API")
        
        candidate = candidates[0]
        content = candidate.get("content", {})
        
        # Check if content has parts
        parts = content.get("parts", [])
        if not parts:
            logging.error(f"No parts in content: {content}")
            raise HTTPException(status_code=500, detail="No content parts returned from Gemini API")
        
        # Extract text from the first part
        output_text = parts[0].get("text", "")
        
        if not output_text:
            logging.error(f"No text in response parts: {parts[0]}")
            raise HTTPException(status_code=500, detail="Empty response from Gemini API")
            
        return GenerateTextResponse(output_text=output_text)
        
    except (KeyError, IndexError, TypeError) as e:
        logging.error(f"Error parsing Gemini response structure: {e}")
        logging.error(f"Full response data: {data}")
        raise HTTPException(status_code=500, detail=f"Unexpected response structure from Gemini API: {str(e)}")