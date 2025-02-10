package services

import (
	"context"
	"log"
	"weddingform/server/models"

	"go.mongodb.org/mongo-driver/mongo"
)

type MongoDb struct {
	client *mongo.Client
	config *models.ConfigContainer
}

func NewMongoDb(client *mongo.Client, config *models.ConfigContainer) *MongoDb {
	return &MongoDb{client: client, config: config}
}

func (m *MongoDb) Close() {
	m.client.Disconnect(context.Background())
}

func (m *MongoDb) InsertNewForm(formData *models.FormData) error {
	collection := m.client.Database(m.config.Database).Collection(m.config.Collection)
	_, err := collection.InsertOne(context.Background(), formData)
	if err != nil {
		log.Println(err)
		return err
	}
	return nil
}
