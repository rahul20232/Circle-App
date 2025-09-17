from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from pydantic import BaseModel
import httpx
import os
import logging
import base64
from typing import Optional
from PIL import Image
import io

# Configure logging
logging.basicConfig(level=logging.INFO)

router = APIRouter(
    prefix="/gemini-edit",
    tags=["Gemini Image Edit"]
)

class EditImageResponse(BaseModel):
    edited_image_base64: str
    mime_type: str

# Helper function to process images
def process_image_for_gemini(image_data: bytes) -> str:
    """Process uploaded image and return base64 encoded data"""
    try:
        # Open and validate the image
        image = Image.open(io.BytesIO(image_data))
        
        # Convert to RGB if necessary
        if image.mode not in ['RGB', 'RGBA']:
            image = image.convert('RGB')
        
        # Resize if too large (max 2048x2048)
        max_size = 2048
        if image.width > max_size or image.height > max_size:
            image.thumbnail((max_size, max_size), Image.Resampling.LANCZOS)
        
        # Convert back to bytes
        output = io.BytesIO()
        image.save(output, format='JPEG', quality=95)
        output.seek(0)
        
        # Encode to base64
        return base64.b64encode(output.getvalue()).decode('utf-8')
        
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid image format: {str(e)}")

# Main image editing endpoint using Gemini 2.5 Flash Image
@router.post("/edit-image", response_model=EditImageResponse)
async def edit_image_with_gemini(
    prompt: str = Form(...),
    image: UploadFile = File(...)
):
    """Edit an image using Gemini 2.5 Flash Image model"""
    
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="GEMINI_API_KEY not set")
    
    # Validate image file
    if not image.content_type or not image.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="Uploaded file must be an image")
    
    try:
        # Read and process the image
        image_data = await image.read()
        image_base64 = process_image_for_gemini(image_data)
        
        # Use Gemini 2.5 Flash Image for editing
        url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image-preview:generateContent"
        headers = {
            "Content-Type": "application/json",
            "x-goog-api-key": api_key
        }
        
        # Create the payload for Gemini image editing
        payload = {
            "contents": [
                {
                    "parts": [
                        {
                            "inline_data": {
                                "mime_type": "image/jpeg",
                                "data": image_base64
                            }
                        },
                        {
                            "text": prompt
                        }
                    ]
                }
            ],
            "generation_config": {
                "response_modalities": ["TEXT", "IMAGE"]
            }
        }

        logging.info(f"Gemini edit request to: {url}")
        logging.info(f"Edit prompt: {prompt}")

        async with httpx.AsyncClient(timeout=90.0) as client:  # Longer timeout for image editing
            response = await client.post(url, headers=headers, json=payload)

        logging.info(f"Gemini edit response status: {response.status_code}")
        
        if response.status_code != 200:
            logging.error(f"Gemini edit error response: {response.text}")
            try:
                error_data = response.json()
                error_message = error_data.get("error", {}).get("message", "Unknown error")
                raise HTTPException(
                    status_code=response.status_code, 
                    detail=f"Gemini image edit error: {error_message}"
                )
            except:
                raise HTTPException(
                    status_code=response.status_code, 
                    detail=f"Gemini image edit error: {response.text}"
                )

        # Parse the response
        data = response.json()
        logging.info(f"Full Gemini response: {data}")
        
        # Look for image data in the response
        candidates = data.get("candidates", [])
        if not candidates:
            raise HTTPException(status_code=500, detail="No candidates in response")
        
        # Look for image parts in the response
        content = candidates[0].get("content", {})
        parts = content.get("parts", [])
        
        logging.info(f"Response parts: {[part.keys() for part in parts]}")
        
        edited_image_data = None
        for part in parts:
            if "inlineData" in part:  # Use camelCase - this is the correct key!
                edited_image_data = part["inlineData"]["data"]
                logging.info("Found image data in inlineData")
                break
            elif "inline_data" in part:  # Fallback to snake_case just in case
                edited_image_data = part["inline_data"]["data"]
                logging.info("Found image data in inline_data")
                break
        
        if not edited_image_data:
            logging.error(f"No image data in response. Available part keys: {[part.keys() for part in parts]}")
            logging.error(f"Full response: {data}")
            raise HTTPException(status_code=500, detail="No edited image returned from Gemini")
            
        return EditImageResponse(
            edited_image_base64=edited_image_data,
            mime_type="image/jpeg"
        )
        
    except httpx.RequestError as e:
        logging.error(f"Gemini edit request failed: {e}")
        raise HTTPException(status_code=500, detail=f"Request to Gemini failed: {str(e)}")
    except Exception as e:
        logging.error(f"Error processing image edit: {e}")
        raise HTTPException(status_code=400, detail=f"Error processing image edit: {str(e)}")

# Direct image response endpoint
from fastapi.responses import Response

@router.post("/edit-image-direct")
async def edit_image_direct(
    prompt: str = Form(...),
    image: UploadFile = File(...)
):
    """Edit image and return directly as image response"""
    
    edit_response = await edit_image_with_gemini(prompt=prompt, image=image)
    
    try:
        image_bytes = base64.b64decode(edit_response.edited_image_base64)
        
        return Response(
            content=image_bytes,
            media_type=edit_response.mime_type,
            headers={"Content-Disposition": "inline; filename=edited_image.jpg"}
        )
        
    except Exception as e:
        logging.error(f"Error decoding edited image: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to decode edited image: {str(e)}")

# Test endpoint to check if the model works
@router.get("/test-model")
async def test_gemini_image_model():
    """Test if Gemini 2.5 Flash Image model is accessible"""
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="GEMINI_API_KEY not set")
    
    url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image-preview:generateContent"
    headers = {
        "Content-Type": "application/json",
        "x-goog-api-key": api_key
    }
    
    # Simple text-to-image test
    payload = {
        "contents": [
            {
                "parts": [
                    {
                        "text": "Create a simple image of a red circle on white background"
                    }
                ]
            }
        ],
        "generation_config": {
            "response_modalities": ["TEXT", "IMAGE"]
        }
    }
    
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(url, headers=headers, json=payload)
        
        if response.status_code == 200:
            return {"status": "success", "message": "Gemini 2.5 Flash Image model is accessible"}
        else:
            return {
                "status": "error", 
                "status_code": response.status_code,
                "error": response.text[:200]
            }
    except Exception as e:
        return {"status": "error", "error": str(e)}


# Debug endpoint to see what Gemini actually returns
@router.post("/debug-edit")
async def debug_edit_image(
    prompt: str = Form(...),
    image: UploadFile = File(...)
):
    """Debug what Gemini returns for image editing"""
    
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="GEMINI_API_KEY not set")
    
    # Validate image file
    if not image.content_type or not image.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="Uploaded file must be an image")
    
    try:
        # Read and process the image
        image_data = await image.read()
        image_base64 = process_image_for_gemini(image_data)
        
        url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image-preview:generateContent"
        headers = {
            "Content-Type": "application/json",
            "x-goog-api-key": api_key
        }
        
        payload = {
            "contents": [
                {
                    "parts": [
                        {
                            "inline_data": {
                                "mime_type": "image/jpeg",
                                "data": image_base64
                            }
                        },
                        {
                            "text": prompt
                        }
                    ]
                }
            ],
            "generation_config": {
                "response_modalities": ["TEXT", "IMAGE"]
            }
        }

        async with httpx.AsyncClient(timeout=90.0) as client:
            response = await client.post(url, headers=headers, json=payload)

        if response.status_code != 200:
            return {
                "status": "error",
                "status_code": response.status_code,
                "error_response": response.text
            }

        data = response.json()
        
        # Return the raw response structure for debugging
        return {
            "status": "success",
            "response_structure": {
                "top_level_keys": list(data.keys()),
                "candidates_count": len(data.get("candidates", [])),
                "first_candidate_keys": list(data.get("candidates", [{}])[0].keys()) if data.get("candidates") else [],
                "content_parts_count": len(data.get("candidates", [{}])[0].get("content", {}).get("parts", [])) if data.get("candidates") else 0,
                "parts_structure": [
                    {
                        "part_index": i,
                        "keys": list(part.keys()),
                        "has_inline_data": "inline_data" in part,
                        "has_inlineData": "inlineData" in part,
                        "has_text": "text" in part
                    }
                    for i, part in enumerate(data.get("candidates", [{}])[0].get("content", {}).get("parts", []))
                ] if data.get("candidates") else []
            },
            "sample_text_content": data.get("candidates", [{}])[0].get("content", {}).get("parts", [{}])[0].get("text", "")[:200] if data.get("candidates") else ""
        }
        
    except Exception as e:
        return {"status": "error", "error": str(e)}