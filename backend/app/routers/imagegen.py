from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from pydantic import BaseModel
import httpx
import os
import logging
import base64
from typing import Optional
from PIL import Image
import io

# Configure logging to see debug info
logging.basicConfig(level=logging.INFO)

router = APIRouter(
    prefix="/imagen",
    tags=["Imagen"]
)

class GenerateImageRequest(BaseModel):
    prompt: str
    sample_count: Optional[int] = 1  # Number of images to generate (1-4)
    aspect_ratio: Optional[str] = "1:1"  # 1:1, 9:16, 16:9, 3:4, 4:3
    safety_filter_level: Optional[str] = "block_some"
    person_generation: Optional[str] = "dont_allow"

class EditImageRequest(BaseModel):
    prompt: str
    image_base64: str  # Base64 encoded input image
    mask_base64: Optional[str] = None  # Optional mask for selective editing
    sample_count: Optional[int] = 1
    edit_mode: Optional[str] = "inpainting-insert"  # inpainting-insert, inpainting-remove, outpainting

class EditImageResponse(BaseModel):
    images: list[str]  # List of base64 encoded edited images
    mime_type: str

class GenerateImageResponse(BaseModel):
    images: list[str]  # List of base64 encoded images
    mime_type: str

@router.post("/generate-image", response_model=GenerateImageResponse)
async def generate_image(request: GenerateImageRequest):
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="GEMINI_API_KEY not set")

    # Correct Imagen REST API endpoint
    url = "https://generativelanguage.googleapis.com/v1beta/models/imagen-4.0-generate-001:predict"
    headers = {
        "Content-Type": "application/json",
        "x-goog-api-key": api_key  # Note: lowercase 'x-goog-api-key'
    }
    
    # Correct payload structure for Imagen REST API
    payload = {
        "instances": [
            {
                "prompt": request.prompt
            }
        ],
        "parameters": {
            "sampleCount": request.sample_count,
            "aspectRatio": request.aspect_ratio,
            "safetyFilterLevel": request.safety_filter_level,
            "personGeneration": request.person_generation
        }
    }

    # Log the request details for debugging
    logging.info(f"Making request to: {url}")
    logging.info(f"Payload: {payload}")

    try:
        async with httpx.AsyncClient(timeout=60.0) as client:  # Longer timeout for image generation
            response = await client.post(url, headers=headers, json=payload)

        # LOG comprehensive response details
        logging.info(f"Response status: {response.status_code}")
        logging.info(f"Response headers: {dict(response.headers)}")
        
        if response.status_code != 200:
            logging.error(f"Full error response: {response.text}")
            
            # Try to parse error details
            try:
                error_data = response.json()
                error_message = error_data.get("error", {}).get("message", "Unknown error")
                logging.error(f"Parsed error message: {error_message}")
                raise HTTPException(
                    status_code=response.status_code, 
                    detail=f"Imagen API error ({response.status_code}): {error_message}"
                )
            except:
                raise HTTPException(
                    status_code=response.status_code, 
                    detail=f"Imagen API error ({response.status_code}): {response.text}"
                )

        try:
            data = response.json()
            logging.info(f"Successful response data keys: {data.keys() if data else 'None'}")
        except Exception as e:
            logging.error(f"Failed to parse JSON: {e}, response text: {response.text}")
            raise HTTPException(status_code=500, detail=f"Failed to parse response: {response.text}")

        # Parse the Imagen response - the structure should have 'predictions'
        try:
            predictions = data.get("predictions", [])
            if not predictions:
                logging.error(f"No predictions in response. Full response: {data}")
                raise HTTPException(status_code=500, detail="No images returned from Imagen API")
            
            # Extract images from predictions
            images = []
            for prediction in predictions:
                # The image data should be in bytesBase64Encoded
                image_base64 = prediction.get("bytesBase64Encoded", "")
                if image_base64:
                    images.append(image_base64)
            
            if not images:
                logging.error(f"No image data found in predictions: {predictions}")
                raise HTTPException(status_code=500, detail="No image data in response")
                
            return GenerateImageResponse(
                images=images,
                mime_type="image/png"  # Imagen typically returns PNG
            )
            
        except (KeyError, IndexError, TypeError) as e:
            logging.error(f"Error parsing Imagen response structure: {e}")
            logging.error(f"Full response data: {data}")
            raise HTTPException(status_code=500, detail=f"Unexpected response structure: {str(e)}")
            
    except httpx.RequestError as e:
        logging.error(f"Request failed: {e}")
        raise HTTPException(status_code=500, detail=f"Request to Imagen API failed: {str(e)}")


# Alternative with Imagen 3 model
@router.post("/generate-image-v3", response_model=GenerateImageResponse)
async def generate_image_v3(request: GenerateImageRequest):
    """Try with Imagen 3 model"""
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="GEMINI_API_KEY not set")

    url = "https://generativelanguage.googleapis.com/v1beta/models/imagen-3.0-generate-002:predict"
    headers = {
        "Content-Type": "application/json",
        "x-goog-api-key": api_key
    }
    
    payload = {
        "instances": [
            {
                "prompt": request.prompt
            }
        ],
        "parameters": {
            "sampleCount": request.sample_count
        }
    }

    logging.info(f"V3 request to: {url}")
    logging.info(f"V3 payload: {payload}")

    try:
        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(url, headers=headers, json=payload)

        logging.info(f"V3 response status: {response.status_code}")
        
        if response.status_code != 200:
            logging.error(f"V3 error response: {response.text}")
            try:
                error_data = response.json()
                error_message = error_data.get("error", {}).get("message", "Unknown error")
                raise HTTPException(
                    status_code=response.status_code, 
                    detail=f"Imagen 3 API error: {error_message}"
                )
            except:
                raise HTTPException(
                    status_code=response.status_code, 
                    detail=f"Imagen 3 API error: {response.text}"
                )

        data = response.json()
        predictions = data.get("predictions", [])
        if not predictions:
            raise HTTPException(status_code=500, detail="No predictions from Imagen 3")
        
        images = []
        for prediction in predictions:
            image_base64 = prediction.get("bytesBase64Encoded", "")
            if image_base64:
                images.append(image_base64)
        
        if not images:
            raise HTTPException(status_code=500, detail="No image data from Imagen 3")
            
        return GenerateImageResponse(
            images=images,
            mime_type="image/png"
        )
        
    except httpx.RequestError as e:
        logging.error(f"V3 request failed: {e}")
        raise HTTPException(status_code=500, detail=f"Imagen 3 request failed: {str(e)}")


# Endpoint to return first image directly
from fastapi.responses import Response

@router.post("/generate-image-direct")
async def generate_image_direct(request: GenerateImageRequest):
    """Generate image and return as direct image response"""
    
    image_response = await generate_image(request)
    
    if not image_response.images:
        raise HTTPException(status_code=500, detail="No images generated")
    
    try:
        # Decode the first image
        image_bytes = base64.b64decode(image_response.images[0])
        
        return Response(
            content=image_bytes,
            media_type=image_response.mime_type,
            headers={"Content-Disposition": "inline; filename=generated_image.png"}
        )
        
    except Exception as e:
        logging.error(f"Error decoding image: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to decode image: {str(e)}")


# Test endpoint that tries both models
@router.post("/test-both-models")
async def test_both_models(request: GenerateImageRequest):
    """Test both Imagen 4 and Imagen 3 models"""
    results = {}
    
    # Test Imagen 4
    try:
        result4 = await generate_image(request)
        results["imagen_4"] = {
            "status": "success",
            "image_count": len(result4.images),
            "mime_type": result4.mime_type
        }
    except Exception as e:
        results["imagen_4"] = {
            "status": "error",
            "error": str(e)
        }
    
    # Test Imagen 3
    try:
        result3 = await generate_image_v3(request)
        results["imagen_3"] = {
            "status": "success", 
            "image_count": len(result3.images),
            "mime_type": result3.mime_type
        }
    except Exception as e:
        results["imagen_3"] = {
            "status": "error",
            "error": str(e)
        }
    
    return results


# Helper function to validate and process images
def process_image_for_editing(image_data: bytes) -> str:
    """Process uploaded image and return base64 encoded data"""
    try:
        # Open and validate the image
        image = Image.open(io.BytesIO(image_data))
        
        # Convert to RGB if necessary
        if image.mode not in ['RGB', 'RGBA']:
            image = image.convert('RGB')
        
        # Resize if too large (max 2048x2048 for Imagen)
        max_size = 2048
        if image.width > max_size or image.height > max_size:
            image.thumbnail((max_size, max_size), Image.Resampling.LANCZOS)
        
        # Convert back to bytes
        output = io.BytesIO()
        image.save(output, format='PNG')
        output.seek(0)
        
        # Encode to base64
        return base64.b64encode(output.getvalue()).decode('utf-8')
        
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid image format: {str(e)}")


# Image editing endpoint with base64 input
@router.post("/edit-image", response_model=EditImageResponse)
async def edit_image(request: EditImageRequest):
    """Edit an image using Imagen with text prompt"""
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="GEMINI_API_KEY not set")

    # Use Imagen 4 for editing
    url = "https://generativelanguage.googleapis.com/v1beta/models/imagen-4.0-generate-001:predict"
    headers = {
        "Content-Type": "application/json",
        "x-goog-api-key": api_key
    }
    
    # Build the payload for image editing
    instance = {
        "prompt": request.prompt,
        "image": {
            "bytesBase64Encoded": request.image_base64
        }
    }
    
    # Add mask if provided
    if request.mask_base64:
        instance["mask"] = {
            "bytesBase64Encoded": request.mask_base64
        }
    
    payload = {
        "instances": [instance],
        "parameters": {
            "sampleCount": request.sample_count,
            "editMode": request.edit_mode
        }
    }

    logging.info(f"Edit image request to: {url}")
    logging.info(f"Edit mode: {request.edit_mode}")
    logging.info(f"Has mask: {bool(request.mask_base64)}")

    try:
        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(url, headers=headers, json=payload)

        logging.info(f"Edit response status: {response.status_code}")
        
        if response.status_code != 200:
            logging.error(f"Edit error response: {response.text}")
            try:
                error_data = response.json()
                error_message = error_data.get("error", {}).get("message", "Unknown error")
                raise HTTPException(
                    status_code=response.status_code, 
                    detail=f"Image edit error: {error_message}"
                )
            except:
                raise HTTPException(
                    status_code=response.status_code, 
                    detail=f"Image edit error: {response.text}"
                )

        data = response.json()
        predictions = data.get("predictions", [])
        if not predictions:
            raise HTTPException(status_code=500, detail="No edited images returned")
        
        images = []
        for prediction in predictions:
            image_base64 = prediction.get("bytesBase64Encoded", "")
            if image_base64:
                images.append(image_base64)
        
        if not images:
            raise HTTPException(status_code=500, detail="No image data in edit response")
            
        return EditImageResponse(
            images=images,
            mime_type="image/png"
        )
        
    except httpx.RequestError as e:
        logging.error(f"Edit request failed: {e}")
        raise HTTPException(status_code=500, detail=f"Edit request failed: {str(e)}")


# Image editing endpoint with file upload
@router.post("/edit-image-upload", response_model=EditImageResponse)
async def edit_image_upload(
    prompt: str = Form(...),
    image: UploadFile = File(...),
    mask: Optional[UploadFile] = File(None),
    sample_count: int = Form(1),
    edit_mode: str = Form("inpainting-insert")
):
    """Edit an uploaded image using Imagen with text prompt"""
    
    # Validate image file
    if not image.content_type or not image.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="Uploaded file must be an image")
    
    try:
        # Read and process the main image
        image_data = await image.read()
        image_base64 = process_image_for_editing(image_data)
        
        # Process mask if provided
        mask_base64 = None
        if mask:
            if not mask.content_type or not mask.content_type.startswith('image/'):
                raise HTTPException(status_code=400, detail="Mask file must be an image")
            mask_data = await mask.read()
            mask_base64 = process_image_for_editing(mask_data)
        
        # Create request object and call the main edit function
        edit_request = EditImageRequest(
            prompt=prompt,
            image_base64=image_base64,
            mask_base64=mask_base64,
            sample_count=sample_count,
            edit_mode=edit_mode
        )
        
        return await edit_image(edit_request)
        
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error processing uploaded files: {str(e)}")


# Outpainting endpoint (expand image boundaries)
@router.post("/outpaint-image", response_model=EditImageResponse)
async def outpaint_image(
    prompt: str = Form(...),
    image: UploadFile = File(...),
    sample_count: int = Form(1)
):
    """Expand an image using outpainting"""
    
    if not image.content_type or not image.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="Uploaded file must be an image")
    
    try:
        image_data = await image.read()
        image_base64 = process_image_for_editing(image_data)
        
        edit_request = EditImageRequest(
            prompt=prompt,
            image_base64=image_base64,
            sample_count=sample_count,
            edit_mode="outpainting"
        )
        
        return await edit_image(edit_request)
        
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error processing outpainting request: {str(e)}")


# Image variation endpoint
@router.post("/vary-image", response_model=EditImageResponse)
async def vary_image(
    prompt: str = Form("Create a variation of this image"),
    image: UploadFile = File(...),
    sample_count: int = Form(4)
):
    """Create variations of an image"""
    
    if not image.content_type or not image.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="Uploaded file must be an image")
    
    try:
        image_data = await image.read()
        image_base64 = process_image_for_editing(image_data)
        
        edit_request = EditImageRequest(
            prompt=prompt,
            image_base64=image_base64,
            sample_count=sample_count,
            edit_mode="inpainting-insert"
        )
        
        return await edit_image(edit_request)
        
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error creating image variations: {str(e)}")


# Return edited image directly
@router.post("/edit-image-direct")
async def edit_image_direct(
    prompt: str = Form(...),
    image: UploadFile = File(...),
    mask: Optional[UploadFile] = File(None),
    edit_mode: str = Form("inpainting-insert")
):
    """Edit image and return directly as image response"""
    
    edit_response = await edit_image_upload(
        prompt=prompt,
        image=image,
        mask=mask,
        sample_count=1,
        edit_mode=edit_mode
    )
    
    if not edit_response.images:
        raise HTTPException(status_code=500, detail="No edited images generated")
    
    try:
        image_bytes = base64.b64decode(edit_response.images[0])
        
        return Response(
            content=image_bytes,
            media_type=edit_response.mime_type,
            headers={"Content-Disposition": "inline; filename=edited_image.png"}
        )
        
    except Exception as e:
        logging.error(f"Error decoding edited image: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to decode edited image: {str(e)}")