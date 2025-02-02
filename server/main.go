package main

import (
	"log"
	"weddingform/server/services"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
)

func main() {
	configContainer := services.GetConfigFromEnvs()
	apiService := services.NewApiService(configContainer)

	app := fiber.New()

	app.Use(cors.New(cors.Config{
		AllowOrigins: "*",
		AllowMethods: "GET, POST, PUT, DELETE",
	}))

	limiter := services.GetLimiter()

	app.Static("/", "./webapp")

	app.Post("/validate-password", limiter, apiService.ValidatePassword)

	app.Post("/send-email", limiter, services.GetBasicAuth(configContainer))

	log.Fatal(app.Listen(":3000"))
}
