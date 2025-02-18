package main

import (
	"log"
	"weddingform/server/mongo"
	"weddingform/server/services"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
)

func main() {
	defer mongo.Close()

	app := fiber.New()

	app.Use(cors.New(cors.Config{
		AllowOrigins: "*",
		AllowMethods: "GET, POST, PUT, DELETE",
	}))

	limiter := services.GetLimiter()

	app.Static("/", "./webapp")

	app.Post("/validate-password", limiter, services.ValidatePassword)

	app.Post("/send-email", limiter, services.GetBasicAuth(), services.GetFormData)

	log.Fatal(app.Listen(":3000"))
}
