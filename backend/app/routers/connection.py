# backend/app/routers/connection.py
from app.models.notification import NotificationType
from app.services.notification_service import NotificationService
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import or_, and_
from typing import List

from app.database import get_db
from app.models.connection import Connection, ConnectionStatus
from app.models.user import User
from app.core.security import get_current_user
from app.services.connection_service import ConnectionService

router = APIRouter(prefix="/connections", tags=["connections"])


@router.post("/send-request")
async def send_connection_request(
    receiver_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Send a connection request to another user"""
    try:
        # Check if receiver exists
        receiver = db.query(User).filter(User.id == receiver_id).first()
        if not receiver:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        connection = ConnectionService.send_connection_request(
            db, current_user.id, receiver_id
        )

        NotificationService.create_notification(
            db=db,
            user_id=receiver_id,
            notification_type=NotificationType.CONNECTION_REQUEST,
            title="New Connection Request",
            message=f"{current_user.display_name} wants to connect with you",
            connection_id=connection.id
        )
        
        return {
            "message": "Connection request sent successfully",
            "connection_id": connection.id
        }
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )


@router.put("/accept/{connection_id}")
async def accept_connection_request(
    connection_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Accept a connection request"""
    try:
        connection = ConnectionService.accept_connection_request(
            db, connection_id, current_user.id
        )
        
        # Get the other user (the sender of the request)
        other_user = db.query(User).filter(User.id == connection.sender_id).first()

        # **ADD THIS: Mark the related connection request notification as read**
        from app.models.notification import Notification  # Import if not already imported
        
        notification = db.query(Notification).filter(
            Notification.connection_id == connection_id,
            Notification.user_id == current_user.id,
            Notification.type == NotificationType.CONNECTION_REQUEST
        ).first()
        
        if notification:
            notification.is_read = True
            print(f"Marked notification {notification.id} as read for connection {connection_id}")

        # Create acceptance notification for the sender
        NotificationService.create_notification(
            db=db,
            user_id=connection.sender_id,
            notification_type=NotificationType.CONNECTION_ACCEPTED,
            title="Connection Request Accepted",
            message=f"{current_user.display_name} accepted your connection request"
        )
        
        # Commit all changes
        db.commit()
        
        return {
            "message": "Connection request accepted",
            "connection_id": connection.id,
            "other_user_id": connection.sender_id,
            "other_user_name": other_user.display_name if other_user else "Unknown"
        }
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.put("/reject/{connection_id}")
async def reject_connection_request(
    connection_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Reject a connection request"""
    try:
        connection = ConnectionService.reject_connection_request(
            db, connection_id, current_user.id
        )
        
        return {
            "message": "Connection request rejected",
            "connection_id": connection.id
        }
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.delete("/remove/{user_id}")
async def remove_connection(
    user_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Remove an existing connection between current user and specified user"""
    try:
        # Check if the target user exists
        target_user = db.query(User).filter(User.id == user_id).first()
        if not target_user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        # Prevent users from "removing" themselves
        if current_user.id == user_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot remove connection with yourself"
            )
        
        # Find the connection between the two users
        connection = db.query(Connection).filter(
            or_(
                and_(Connection.sender_id == current_user.id, Connection.receiver_id == user_id),
                and_(Connection.sender_id == user_id, Connection.receiver_id == current_user.id)
            )
        ).first()
        
        if not connection:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="No connection found between users"
            )
        
        # Only allow removal of accepted connections
        if connection.status != ConnectionStatus.ACCEPTED:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Can only remove accepted connections"
            )
        
        # Delete the connection from database
        db.delete(connection)
        db.commit()
        
        return {
            "message": f"Connection with {target_user.display_name} removed successfully",
            "removed_user_id": user_id,
            "removed_user_name": target_user.display_name
        }
        
    except HTTPException:
        # Re-raise HTTP exceptions
        raise
    except Exception as e:
        # Handle any other unexpected errors
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to remove connection: {str(e)}"
        )
    
@router.get("/my-connections")
async def get_my_connections(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get all accepted connections for the current user"""
    connections = ConnectionService.get_user_connections(
        db, current_user.id, ConnectionStatus.ACCEPTED
    )
    
    user_list = []
    for user in connections:
        user_list.append({
            "id": user.id,
            "display_name": user.display_name,
            "email": user.email,
            "profile_picture_url": user.profile_picture_url,
            "industry": user.industry
        })
    
    return {
        "total_connections": len(user_list),
        "connections": user_list
    }


@router.get("/pending-requests")
async def get_pending_requests(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get all pending connection requests received by the current user"""
    pending_requests = ConnectionService.get_pending_requests(
        db, current_user.id
    )
    
    requests_list = []
    for connection in pending_requests:
        sender = connection.sender
        requests_list.append({
            "connection_id": connection.id,
            "sender": {
                "id": sender.id,
                "display_name": sender.display_name,
                "profile_picture_url": sender.profile_picture_url,
                "industry": sender.industry
            },
            "created_at": connection.created_at
        })
    
    return {
        "total_requests": len(requests_list),
        "requests": requests_list
    }



@router.get("/status/{user_id}")
async def get_connection_status_with_user(
    user_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get connection status between current user and specified user"""
    status_info = ConnectionService.get_connection_status(
        db, current_user.id, user_id
    )
    
    # Ensure the response includes all fields needed by frontend
    return {
        "already_connected": status_info.get("already_connected", False),
        "connection_request_sent": status_info.get("connection_request_sent", False),
        "pending_request_received": status_info.get("pending_request_received", False),
        "connection_id": status_info.get("connection_id", None)
    }