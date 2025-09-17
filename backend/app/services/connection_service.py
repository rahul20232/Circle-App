# backend/app/services/connection_service.py
from sqlalchemy.orm import Session
from sqlalchemy import or_, and_
from app.models.connection import Connection, ConnectionStatus
from app.models.user import User
from typing import Dict, List, Optional
from datetime import datetime


class ConnectionService:
    
    @staticmethod
    def get_connection_status(db: Session, user1_id: int, user2_id: int) -> Dict[str, bool]:
        """
        Get connection status between two users
        Returns dict with connection_request_sent and already_connected flags
        """
        # Check if there's any connection between these users
        connection = db.query(Connection).filter(
            or_(
                and_(Connection.sender_id == user1_id, Connection.receiver_id == user2_id),
                and_(Connection.sender_id == user2_id, Connection.receiver_id == user1_id)
            )
        ).first()
        
        if not connection:
            return {
                "connection_request_sent": False,
                "already_connected": False
            }
        
        # Check if they're already connected (accepted)
        if connection.status == ConnectionStatus.ACCEPTED:
            return {
                "connection_request_sent": False,
                "already_connected": True
            }
        
        # Check if current user has sent a pending request
        if (connection.status == ConnectionStatus.PENDING and 
            connection.sender_id == user1_id):
            return {
                "connection_request_sent": True,
                "already_connected": False
            }
        
        # Other cases (rejected, blocked, or pending from other user)
        return {
            "connection_request_sent": False,
            "already_connected": False
        }
    
    @staticmethod
    def send_connection_request(db: Session, sender_id: int, receiver_id: int) -> Connection:
        """
        Send a connection request from sender to receiver
        """
        if sender_id == receiver_id:
            raise ValueError("Cannot send connection request to yourself")
        
        # Check if connection already exists
        existing_connection = db.query(Connection).filter(
            or_(
                and_(Connection.sender_id == sender_id, Connection.receiver_id == receiver_id),
                and_(Connection.sender_id == receiver_id, Connection.receiver_id == sender_id)
            )
        ).first()
        
        if existing_connection:
            if existing_connection.status == ConnectionStatus.ACCEPTED:
                raise ValueError("Users are already connected")
            elif existing_connection.status == ConnectionStatus.PENDING:
                raise ValueError("Connection request already pending")
            elif existing_connection.status == ConnectionStatus.REJECTED:
                # Allow resending after rejection, update existing record
                existing_connection.sender_id = sender_id
                existing_connection.receiver_id = receiver_id
                existing_connection.status = ConnectionStatus.PENDING
                existing_connection.updated_at = datetime.utcnow()
                db.commit()
                db.refresh(existing_connection)
                return existing_connection
        
        # Create new connection request
        new_connection = Connection(
            sender_id=sender_id,
            receiver_id=receiver_id,
            status=ConnectionStatus.PENDING
        )
        
        db.add(new_connection)
        db.commit()
        db.refresh(new_connection)
        
        return new_connection
    
    @staticmethod
    def accept_connection_request(db: Session, connection_id: int, user_id: int) -> Connection:
        """
        Accept a connection request (only receiver can accept)
        """
        connection = db.query(Connection).filter(
            Connection.id == connection_id,
            Connection.receiver_id == user_id,
            Connection.status == ConnectionStatus.PENDING
        ).first()
        
        if not connection:
            raise ValueError("Connection request not found or not authorized")
        
        connection.status = ConnectionStatus.ACCEPTED
        connection.updated_at = datetime.utcnow()
        db.commit()
        db.refresh(connection)
        
        return connection
    
    @staticmethod
    def reject_connection_request(db: Session, connection_id: int, user_id: int) -> Connection:
        """
        Reject a connection request (only receiver can reject)
        """
        connection = db.query(Connection).filter(
            Connection.id == connection_id,
            Connection.receiver_id == user_id,
            Connection.status == ConnectionStatus.PENDING
        ).first()
        
        if not connection:
            raise ValueError("Connection request not found or not authorized")
        
        connection.status = ConnectionStatus.REJECTED
        connection.updated_at = datetime.utcnow()
        db.commit()
        db.refresh(connection)
        
        return connection
    
    @staticmethod
    def get_user_connections(db: Session, user_id: int, status: ConnectionStatus = ConnectionStatus.ACCEPTED) -> List[User]:
        """
        Get all connected users for a given user
        """
        connections = db.query(Connection).filter(
            or_(
                Connection.sender_id == user_id,
                Connection.receiver_id == user_id
            ),
            Connection.status == status
        ).all()
        
        connected_users = []
        for connection in connections:
            # Get the other user in the connection
            other_user_id = connection.receiver_id if connection.sender_id == user_id else connection.sender_id
            user = db.query(User).filter(User.id == other_user_id).first()
            if user:
                connected_users.append(user)
        
        return connected_users
    
    @staticmethod
    def get_pending_requests(db: Session, user_id: int) -> List[Connection]:
        """
        Get all pending connection requests received by a user
        """
        return db.query(Connection).filter(
            Connection.receiver_id == user_id,
            Connection.status == ConnectionStatus.PENDING
        ).all()