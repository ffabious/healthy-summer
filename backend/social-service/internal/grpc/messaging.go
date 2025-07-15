package grpc

import (
	"context"
	"fmt"
	"log"
	"sync"
	"time"

	"github.com/ffabious/healthy-summer/social-service/internal/db"
	"github.com/ffabious/healthy-summer/social-service/internal/model"
	pb "github.com/ffabious/healthy-summer/social-service/proto"
	"github.com/google/uuid"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type MessagingServer struct {
	pb.UnimplementedMessagingServiceServer
	clients map[string]chan *pb.MessageEvent
	mu      sync.RWMutex
}

func NewMessagingServer() *MessagingServer {
	return &MessagingServer{
		clients: make(map[string]chan *pb.MessageEvent),
	}
}

func (s *MessagingServer) SendMessage(ctx context.Context, req *pb.SendMessageRequest) (*pb.SendMessageResponse, error) {
	// Parse UUIDs
	senderID, err := getUUIDFromContext(ctx)
	if err != nil {
		return &pb.SendMessageResponse{
			Success: false,
			Error:   "Invalid sender ID",
		}, nil
	}

	receiverID, err := uuid.Parse(req.ReceiverId)
	if err != nil {
		return &pb.SendMessageResponse{
			Success: false,
			Error:   "Invalid receiver ID",
		}, nil
	}

	// Create message
	message := &model.Message{
		SenderID:    senderID,
		ReceiverID:  receiverID,
		Content:     req.Content,
		MessageType: req.MessageType,
		IsRead:      false,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}

	if message.MessageType == "" {
		message.MessageType = "text"
	}

	// Save to database
	if err := db.CreateMessage(message); err != nil {
		return &pb.SendMessageResponse{
			Success: false,
			Error:   "Failed to save message",
		}, nil
	}

	// Update conversation
	conversation, err := db.GetOrCreateConversation(senderID, receiverID)
	if err != nil {
		log.Printf("Failed to update conversation: %v", err)
	} else {
		db.UpdateConversationLastMessage(conversation.ID, message.ID)
	}

	// Convert to protobuf message
	pbMessage := &pb.Message{
		Id:          message.ID.String(),
		SenderId:    message.SenderID.String(),
		ReceiverId:  message.ReceiverID.String(),
		Content:     message.Content,
		MessageType: message.MessageType,
		IsRead:      message.IsRead,
		CreatedAt:   timestamppb.New(message.CreatedAt),
	}

	// Broadcast to connected clients
	s.broadcastMessage(&pb.MessageEvent{
		EventType: "new_message",
		Message:   pbMessage,
	}, []string{req.ReceiverId, senderID.String()})

	return &pb.SendMessageResponse{
		Message: pbMessage,
		Success: true,
	}, nil
}

func (s *MessagingServer) StreamMessages(req *pb.StreamRequest, stream pb.MessagingService_StreamMessagesServer) error {
	userID := req.UserId
	
	// Create a channel for this client
	clientChan := make(chan *pb.MessageEvent, 100)
	
	// Register client
	s.mu.Lock()
	s.clients[userID] = clientChan
	s.mu.Unlock()

	// Clean up when done
	defer func() {
		s.mu.Lock()
		delete(s.clients, userID)
		close(clientChan)
		s.mu.Unlock()
	}()

	// Send messages to client
	for {
		select {
		case msg, ok := <-clientChan:
			if !ok {
				return nil
			}
			if err := stream.Send(msg); err != nil {
				log.Printf("Error sending message to client %s: %v", userID, err)
				return err
			}
		case <-stream.Context().Done():
			return stream.Context().Err()
		}
	}
}

func (s *MessagingServer) MarkAsRead(ctx context.Context, req *pb.MarkAsReadRequest) (*pb.MarkAsReadResponse, error) {
	userID, err := getUUIDFromContext(ctx)
	if err != nil {
		return &pb.MarkAsReadResponse{
			Success: false,
			Error:   "Invalid user ID",
		}, nil
	}

	// Parse message IDs
	var messageIDs []uuid.UUID
	for _, idStr := range req.MessageIds {
		id, err := uuid.Parse(idStr)
		if err != nil {
			return &pb.MarkAsReadResponse{
				Success: false,
				Error:   "Invalid message ID format",
			}, nil
		}
		messageIDs = append(messageIDs, id)
	}

	// Mark messages as read
	if err := db.MarkMessagesAsRead(messageIDs, userID); err != nil {
		return &pb.MarkAsReadResponse{
			Success: false,
			Error:   "Failed to mark messages as read",
		}, nil
	}

	// Broadcast read event to sender
	s.broadcastReadEvent(messageIDs, userID)

	return &pb.MarkAsReadResponse{
		Success: true,
	}, nil
}

func (s *MessagingServer) broadcastMessage(event *pb.MessageEvent, userIDs []string) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	for _, userID := range userIDs {
		if clientChan, exists := s.clients[userID]; exists {
			select {
			case clientChan <- event:
			default:
				log.Printf("Client %s message queue is full", userID)
			}
		}
	}
}

func (s *MessagingServer) broadcastReadEvent(messageIDs []uuid.UUID, readerID uuid.UUID) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	event := &pb.MessageEvent{
		EventType: "messages_read",
		Message: &pb.Message{
			ReceiverId: readerID.String(),
		},
	}

	// This is simplified - in a real implementation, you'd want to send this
	// to the senders of the read messages
	for userID, clientChan := range s.clients {
		if userID != readerID.String() {
			select {
			case clientChan <- event:
			default:
				log.Printf("Client %s message queue is full", userID)
			}
		}
	}
}

func getUUIDFromContext(ctx context.Context) (uuid.UUID, error) {
	// In a real implementation, you'd extract this from JWT token in context
	// For now, we'll use a placeholder
	if userID := ctx.Value("userID"); userID != nil {
		if id, ok := userID.(uuid.UUID); ok {
			return id, nil
		}
		if idStr, ok := userID.(string); ok {
			return uuid.Parse(idStr)
		}
	}
	return uuid.Nil, fmt.Errorf("user ID not found in context")
}
