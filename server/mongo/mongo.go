package mongo

import (
	"context"
	"log"
	"weddingform/server/config"
	"weddingform/server/models"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var (
	configuration *models.ConfigContainer
	client        *mongo.Client
)

func init() {
	ctx := context.Background()

	configuration = config.GetConfig()

	mongoClient, err := mongo.Connect(ctx, options.Client().ApplyURI(configuration.MongoUri))
	if err != nil {
		panic(err)
	}

	client = mongoClient
}

func Close() {
	client.Disconnect(context.Background())
}

func InsertNewForm(formData *models.FormData) error {
	collection := client.Database(configuration.Database).Collection(configuration.Collection)
	_, err := collection.InsertOne(context.Background(), *formData)
	if err != nil {
		log.Println(err)
		return err
	}
	return nil
}
