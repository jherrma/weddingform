package main

import (
	"log"
	"os"
	"strconv"
	"time"

	"net/smtp"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/basicauth"
	"github.com/gofiber/fiber/v2/middleware/limiter"
	"github.com/joho/godotenv"
)

type FormData struct {
	// general
	Name               string `json:"name"`
	IsComing           bool   `json:"isComing"`
	WhoIsComing        string `json:"whoIsComing"`
	NumberOfPeople     int    `json:"numberOfPeople"`
	ContactInformation string `json:"contactInformation"`

	// contribution
	DoYouHaveContribution bool   `json:"doYouHaveContribution"`
	Topic                 string `json:"topic"`
	NeedProjector         bool   `json:"needProjector"`
	NeedMusic             bool   `json:"needMusic"`

	// cake
	DoYouBringCake bool   `json:"doYouBringCake"`
	CakeFlavor     string `json:"cakeFlavor"`

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
	EMAIL_RECIPIENT_GENERAL     = "EMAIL_RECIPIENT_GENERAL"
	EMAIL_RECIPIENT_COFFEE      = "EMAIL_RECIPIENT_COFFEE"
	EMAIL_RECIPIENT_FESTIVITIES = "EMAIL_RECIPIENT_FESTIVITIES"
	USER_COFFEE                 = "USER_COFFEE"
	USER_FESTIVITIES            = "USER_FESTIVITIES"
	SECRET_COFFEE               = "SECRET_COFFEE"
	SECRET_FESTIVITIES          = "SECRET_FESTIVITIES"
	SMTP_HOST                   = "SMTP_HOST"
	SMTP_PORT                   = "SMTP_PORT"
	SMTP_USER                   = "SMTP_USER"
	SMTP_PASSWORD               = "SMTP_PASSWORD"
)

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Println("No .env file found")
	}

	app := fiber.New()

	app.Post("/validate-password", limiter.New(limiter.Config{
		Max:        5,
		Expiration: 1 * time.Minute,
		KeyGenerator: func(c *fiber.Ctx) string {
			return c.IP()
		},
		LimitReached: func(c *fiber.Ctx) error {
			return c.Status(fiber.StatusTooManyRequests).JSON(fiber.Map{
				"error": "Too many attempts. Please try again later.",
			})
		},
	}), func(c *fiber.Ctx) error {
		var data PasswordData
		if err := c.BodyParser(&data); err != nil {
			return c.Status(400).JSON(fiber.Map{"error": "Cannot parse JSON"})
		}

		secretCoffee := os.Getenv(SECRET_COFFEE)
		secretFestivities := os.Getenv(SECRET_FESTIVITIES)

		if data.Password == secretCoffee {
			return c.JSON(fiber.Map{
				"type":     0,
				"username": os.Getenv(USER_COFFEE),
				"password": secretCoffee,
			})
		} else if data.Password == secretFestivities {
			return c.JSON(fiber.Map{
				"type":     1,
				"username": os.Getenv(USER_FESTIVITIES),
				"password": secretFestivities,
			})
		} else {
			return c.Status(401).JSON(fiber.Map{
				"error": "Unauthorized",
			})
		}
	})

	app.Post("/send-email", basicauth.New(basicauth.Config{
		Users: map[string]string{
			os.Getenv(USER_COFFEE):      os.Getenv(SECRET_COFFEE),
			os.Getenv(USER_FESTIVITIES): os.Getenv(SECRET_FESTIVITIES),
		},
		Unauthorized: func(c *fiber.Ctx) error {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "Unauthorized",
			})
		},
	}), func(c *fiber.Ctx) error {
		var data FormData
		if err := c.BodyParser(&data); err != nil {
			return c.Status(400).JSON(fiber.Map{"error": "Cannot parse JSON"})
		}

		smtpHost := os.Getenv(SMTP_HOST)
		smtpPort := os.Getenv(SMTP_PORT)
		smtpUser := os.Getenv(SMTP_USER)
		smtpPassword := os.Getenv(SMTP_PASSWORD)

		auth := smtp.PlainAuth("Jonathan Herrmann", smtpUser, smtpPassword, smtpHost)

		// Construct email headers and body
		from := smtpUser
		toGeneral := []string{os.Getenv(EMAIL_RECIPIENT_GENERAL)}
		subjectGeneral := "New Form Submission - General and Meal"
		bodyGeneral := "Name: " + data.Name + "\nContactInformation: " + data.ContactInformation +
			"\nNumberOfPeople: " + strconv.Itoa(data.NumberOfPeople) +
			"\nIs Coming: " + strconv.FormatBool(data.IsComing) +
			"\nStarters Option 1: " + data.StartersOption1 +
			"\nStarters Option 2: " + data.StartersOption2 +
			"\nMain Option 1: " + data.MainOption1 +
			"\nMain Option 2: " + data.MainOption2 +
			"\nMain Option 3: " + data.MainOption3 +
			"\nDessert Option 1: " + data.DessertOption1 +
			"\nDessert Option 2: " + data.DessertOption2
		msgGeneral := "From: " + from + "\n" +
			"To: " + toGeneral[0] + "\n" +
			"Subject: " + subjectGeneral + "\n\n" +
			bodyGeneral

		// Send general email
		err := smtp.SendMail(smtpHost+":"+smtpPort, auth, from, toGeneral, []byte(msgGeneral))
		if err != nil {
			log.Println(err)
			return c.Status(500).JSON(fiber.Map{"error": "Error sending general and meal email"})
		}

		if data.IsComing && data.DoYouBringCake {
			toCoffee := []string{os.Getenv(EMAIL_RECIPIENT_COFFEE)}
			subjectCoffee := "New Form Submission - Cake"
			bodyCoffee := "Name: " + data.Name + "\nContactInformation: " + data.ContactInformation +
				"\nNumberOfPeople: " + strconv.Itoa(data.NumberOfPeople) +
				"\nIs Coming: " + strconv.FormatBool(data.IsComing) +
				"\nDo You Bring Cake: " + strconv.FormatBool(data.DoYouBringCake) +
				"\nCake Flavor: " + data.CakeFlavor
			msgCoffee := "From: " + from + "\n" +
				"To: " + toCoffee[0] + "\n" +
				"Subject: " + subjectCoffee + "\n\n" +
				bodyCoffee

			err = smtp.SendMail(smtpHost+":"+smtpPort, auth, from, toCoffee, []byte(msgCoffee))
			if err != nil {
				log.Println(err)
				return c.Status(500).JSON(fiber.Map{"error": "Error sending general and cake email"})
			}
		}

		if data.IsComing && data.DoYouHaveContribution {
			toFestivities := []string{os.Getenv(EMAIL_RECIPIENT_FESTIVITIES)}
			subjectFestivities := "New Form Submission - Contribution"
			bodyFestivities := "Name: " + data.Name + "\nContactInformation: " + data.ContactInformation +
				"\nNumberOfPeople: " + strconv.Itoa(data.NumberOfPeople) +
				"\nIs Coming: " + strconv.FormatBool(data.IsComing) +
				"\nDo You Have Contribution: " + strconv.FormatBool(data.DoYouHaveContribution) +
				"\nTopic: " + data.Topic +
				"\nNeed Projector: " + strconv.FormatBool(data.NeedProjector) +
				"\nNeed Music: " + strconv.FormatBool(data.NeedMusic)
			msgFestivities := "From: " + from + "\n" +
				"To: " + toFestivities[0] + "\n" +
				"Subject: " + subjectFestivities + "\n\n" +
				bodyFestivities

			err = smtp.SendMail(smtpHost+":"+smtpPort, auth, from, toFestivities, []byte(msgFestivities))
			if err != nil {
				log.Println(err)
				return c.Status(500).JSON(fiber.Map{"error": "Error sending general and contribution email"})
			}
		}

		return c.JSON(fiber.Map{"message": "Emails sent successfully"})
	})

	log.Fatal(app.Listen(":3000"))
}
