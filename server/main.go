package main

import (
	"context"
	"log"
	"weddingform/server/services"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func main() {
	ctx := context.Background()

	configContainer := services.GetConfigFromEnvs()

	client, err := mongo.Connect(ctx, options.Client().ApplyURI(configContainer.MongoUri))
	if err != nil {
		panic(err)
	}

	mongoDb := services.NewMongoDb(client, configContainer)
	defer mongoDb.Close()

	apiService := services.NewApiService(configContainer, mongoDb)

	app := fiber.New()

	app.Use(cors.New(cors.Config{
		AllowOrigins: "*",
		AllowMethods: "GET, POST, PUT, DELETE",
	}))

	limiter := services.GetLimiter()

	app.Static("/", "./webapp")

	app.Post("/validate-password", limiter, apiService.ValidatePassword)

	app.Post("/send-email", limiter, services.GetBasicAuth(configContainer), apiService.GetFormData)

	log.Fatal(app.Listen(":3000"))
}
