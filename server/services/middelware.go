package services

import (
	"time"
	"weddingform/server/models"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/basicauth"
	"github.com/gofiber/fiber/v2/middleware/limiter"
)

func GetLimiter() fiber.Handler {
	return limiter.New(limiter.Config{
		Max:        10,
		Expiration: 1 * time.Minute,
		KeyGenerator: func(c *fiber.Ctx) string {
			return c.IP()
		},
		LimitReached: func(c *fiber.Ctx) error {
			return c.Status(fiber.StatusTooManyRequests).JSON(fiber.Map{
				"error": "Too many attempts. Please try again later.",
			})
		},
	})
}

func GetBasicAuth(configContainer *models.ConfigContainer) fiber.Handler {
	return basicauth.New(basicauth.Config{
		Users: map[string]string{
			configContainer.UsernameCoffee:      configContainer.SecretCoffee,
			configContainer.UsernameFestivities: configContainer.SecretFestivities,
		},
		Unauthorized: func(c *fiber.Ctx) error {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "Unauthorized",
			})
		},
	})
}
