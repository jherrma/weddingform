package main

import (
	"context"
	"log"
	"os"
	"strconv"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/joho/godotenv"
	"github.com/mailgun/mailgun-go/v4"
)

type FormData struct {
	// general
	Name               string `json:"name"`
	IsComing           bool   `json:"is_coming"`
	WhoIsComing        string `json:"who_is_coming"`
	ContactInformation string `json:"contact_information"`

	// contribution
	DoYouHaveContribution bool   `json:"do_you_have_contribution"`
	Topic                 string `json:"topic"`
	NeedProjector         bool   `json:"need_projector"`
	NeedMusic             bool   `json:"need_music"`

	// cake
	DoYouBringCake bool   `json:"do_you_bring_cake"`
	CakeFlavor     string `json:"cake_flavor"`

	// meal
	StartersOption1 string `json:"startersOption1"`
	StartersOption2 string `json:"startersOption2"`
	MainOption1     string `json:"mainOption1"`
	MainOption2     string `json:"mainOption2"`
	MainOption3     string `json:"mainOption3"`
	DessertOption1  string `json:"dessertOption1"`
	DessertOption2  string `json:"dessertOption2"`
}

type PasswordData struct {
	Password string `json:"password"`
}

const (
	MAILGUN_DOMAIN              = "MAILGUN_DOMAIN"
	MAILGUN_API_KEY             = "MAILGUN_API_KEY"
	EMAIL_SENDER                = "EMAIL_SENDER"
	EMAIL_RECIPIENT_GENERAL     = "EMAIL_RECIPIENT_GENERAL"
	EMAIL_RECIPIENT_COFFEE      = "EMAIL_RECIPIENT_COFFEE"
	EMAIL_RECIPIENT_FESTIVITIES = "EMAIL_RECIPIENT_FESTIVITIES"
	SECRET_COFFEE               = "SECRET_COFFEE"
	SECRET_FESTIVITIES          = "SECRET_FESTIVITIES"
)

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Println("No .env file found")
	}

	app := fiber.New()

	app.Post("/validate-password", func(c *fiber.Ctx) error {
		var data PasswordData
		if err := c.BodyParser(&data); err != nil {
			return c.Status(400).JSON(fiber.Map{"error": "Cannot parse JSON"})
		}

		secretCoffee := os.Getenv(SECRET_COFFEE)
		secretFestivities := os.Getenv(SECRET_FESTIVITIES)

		if data.Password == secretCoffee {
			return c.JSON(fiber.Map{"result": 0})
		} else if data.Password == secretFestivities {
			return c.JSON(fiber.Map{"result": 1})
		} else {
			return c.Status(401).JSON(fiber.Map{"error": "Unauthorized"})
		}
	})

	app.Post("/send-email", func(c *fiber.Ctx) error {
		var data FormData
		if err := c.BodyParser(&data); err != nil {
			return c.Status(400).JSON(fiber.Map{"error": "Cannot parse JSON"})
		}

		ctx, cancel := context.WithTimeout(context.Background(), time.Second*10)
		defer cancel()

		domain := os.Getenv(MAILGUN_DOMAIN)
		apiKey := os.Getenv(MAILGUN_API_KEY)
		mg := mailgun.NewMailgun(domain, apiKey)

		sender := os.Getenv(EMAIL_SENDER)

		recipientGeneral := os.Getenv(EMAIL_RECIPIENT_GENERAL)
		subjectGeneral := "New Form Submission"
		bodyGeneral := "Name: " + data.Name + "\nContactInformation: " + data.ContactInformation +
			"\nIs Coming: " + strconv.FormatBool(data.IsComing) +
			"\nStarters Option 1: " + data.StartersOption1 +
			"\nStarters Option 2: " + data.StartersOption2 +
			"\nMain Option 1: " + data.MainOption1 +
			"\nMain Option 2: " + data.MainOption2 +
			"\nMain Option 3: " + data.MainOption3 +
			"\nDessert Option 1: " + data.DessertOption1 +
			"\nDessert Option 2: " + data.DessertOption2

		messageGeneral := mg.NewMessage(sender, subjectGeneral, bodyGeneral, recipientGeneral)

		_, _, err = mg.Send(ctx, messageGeneral)
		if err != nil {
			log.Println(err)
			return c.Status(500).JSON(fiber.Map{"error": "Error sending general and meal email"})
		}

		if data.IsComing && data.DoYouBringCake {
			recipientCoffee := os.Getenv(EMAIL_RECIPIENT_COFFEE)
			subjectCoffee := "New Form Submission"
			bodyCoffee := "Name: " + data.Name + "\nContactInformation: " + data.ContactInformation +
				"\nIs Coming: " + strconv.FormatBool(data.IsComing) +
				"\nDo You Bring Cake: " + strconv.FormatBool(data.DoYouBringCake) +
				"\nCake Flavor: " + data.CakeFlavor

			messageCoffee := mg.NewMessage(sender, subjectCoffee, bodyCoffee, recipientCoffee)

			_, _, err = mg.Send(ctx, messageCoffee)
			if err != nil {
				log.Println(err)
				return c.Status(500).JSON(fiber.Map{"error": "Error sending general and cake email"})
			}
		}

		if data.IsComing && data.DoYouHaveContribution {
			recipientFestivities := os.Getenv(EMAIL_RECIPIENT_FESTIVITIES)
			subjectFestivities := "New Form Submission - General and Contribution"
			bodyFestivities := "Name: " + data.Name + "\nContactInformation: " + data.ContactInformation +
				"\nIs Coming: " + strconv.FormatBool(data.IsComing) +
				"\nDo You Have Contribution: " + strconv.FormatBool(data.DoYouHaveContribution) +
				"\nTopic: " + data.Topic +
				"\nNeed Projector: " + strconv.FormatBool(data.NeedProjector) +
				"\nNeed Music: " + strconv.FormatBool(data.NeedMusic)

			messageFestivities := mg.NewMessage(sender, subjectFestivities, bodyFestivities, recipientFestivities)

			_, _, err = mg.Send(ctx, messageFestivities)
			if err != nil {
				log.Println(err)
				return c.Status(500).JSON(fiber.Map{"error": "Error sending general and contribution email"})
			}
		}

		return c.JSON(fiber.Map{"message": "Emails sent successfully"})
	})

	log.Fatal(app.Listen(":3000"))
}
