package main

import (
	"log"
	"os"
	"strconv"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/basicauth"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/limiter"
	"github.com/joho/godotenv"
	"gopkg.in/gomail.v2"
)

type FormData struct {
	// general
	Name               string `json:"name"`
	IsComing           bool   `json:"isComing"`
	WhoIsComing        string `json:"whoIsComing"`
	ContactInformation string `json:"contactInformation"`
	Notes              string `json:"notes"`

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

	usernameCoffee := os.Getenv(USER_COFFEE)
	usernameFestivities := os.Getenv(USER_FESTIVITIES)

	secretCoffee := os.Getenv(SECRET_COFFEE)
	secretFestivities := os.Getenv(SECRET_FESTIVITIES)

	smtpHost := os.Getenv(SMTP_HOST)
	smtpPort := os.Getenv(SMTP_PORT)
	smtpUser := os.Getenv(SMTP_USER)
	smtpPassword := os.Getenv(SMTP_PASSWORD)

	emailGeneral := os.Getenv(EMAIL_RECIPIENT_GENERAL)
	emailCoffee := os.Getenv(EMAIL_RECIPIENT_COFFEE)
	emailFestivities := os.Getenv(EMAIL_RECIPIENT_FESTIVITIES)

	debugString := os.Getenv("DEBUG")
	debug, err := strconv.ParseBool(debugString)
	if err != nil {
		debug = true
	}

	if debug {
		log.Println("Debug enabled")
	}

	app := fiber.New()

	app.Use(cors.New(cors.Config{
		AllowOrigins: "*",
		AllowMethods: "GET, POST, PUT, DELETE",
	}))

	app.Static("/", "./webapp")

	app.Post("/validate-password", limiter.New(limiter.Config{
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
	}), func(c *fiber.Ctx) error {
		var data PasswordData
		if err := c.BodyParser(&data); err != nil {
			return c.Status(400).JSON(fiber.Map{"error": "Cannot parse JSON"})
		}

		if data.Password == secretCoffee {
			return c.JSON(fiber.Map{
				"type":              0,
				"username":          usernameCoffee,
				"password":          secretCoffee,
				"emailCoffee":       emailCoffee,
				"emailContribution": emailFestivities,
			})
		} else if data.Password == secretFestivities {
			return c.JSON(fiber.Map{
				"type":              1,
				"username":          usernameFestivities,
				"password":          secretFestivities,
				"emailCoffee":       emailCoffee,
				"emailContribution": emailFestivities,
			})
		} else {
			return c.Status(401).JSON(fiber.Map{
				"error": "Unauthorized",
			})
		}
	})

	app.Post("/send-email", limiter.New(limiter.Config{
		Max:        2,
		Expiration: 1 * time.Minute,
		KeyGenerator: func(c *fiber.Ctx) string {
			return c.IP()
		},
		LimitReached: func(c *fiber.Ctx) error {
			return c.Status(fiber.StatusTooManyRequests).JSON(fiber.Map{
				"error": "Too many attempts. Please try again later.",
			})
		},
	}), basicauth.New(basicauth.Config{
		Users: map[string]string{
			usernameCoffee:      secretCoffee,
			usernameFestivities: secretFestivities,
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

		var mailer *gomail.Dialer = nil

		if !debug {
			port, err := strconv.Atoi(smtpPort)
			if err != nil {
				log.Println("Invalid SMTP port")
				return c.Status(500).JSON(fiber.Map{"error": "Invalid SMTP port"})
			}
			mailer = gomail.NewDialer(smtpHost, port, smtpUser, smtpPassword)
			mailer.SSL = false
		}

		from := smtpUser
		toGeneral := []string{emailGeneral}
		subjectGeneral := resolveIsComing(data.IsComing) + " - Hochzeit - Allgemein und Mahlzeiten"
		bodyGeneral := resolveIsComing(data.IsComing) + " von: " + data.Name +
			"\nKommt: " + resolveBool(data.IsComing) +
			"\nWer kommt: " + data.WhoIsComing +
			"\n\nGerichte:\nSchwäbische Hochzeitssuppe: " + data.StartersOption1 +
			"\nBunter Beilagensalat: " + data.StartersOption2 +
			"\nRinderschmorbraten: " + data.MainOption1 +
			"\nHähnchenbrust auf Kräuterkruste: " + data.MainOption2 +
			"\nGebackene Falafel: " + data.MainOption3 +
			"\nCreme brulee: " + data.DessertOption1 +
			"\nMousse au Chocolat: " + data.DessertOption2 +
			"\n\nWas wir noch mitteilen wollen: " + data.Notes +
			"\n\n\nKontaktinformation: " + data.ContactInformation

		msgGeneral := gomail.NewMessage()
		msgGeneral.SetHeader("From", from)
		msgGeneral.SetHeader("To", toGeneral[0])
		msgGeneral.SetHeader("Subject", subjectGeneral)
		msgGeneral.SetBody("text/plain", bodyGeneral)
		if !debug {
			if err := mailer.DialAndSend(msgGeneral); err != nil {
				log.Println(err.Error())
				return c.Status(500).JSON(fiber.Map{"error": "Error sending general and meal email"})
			}
		} else {
			log.Println("General and meal email:")
			log.Println("From: " + from)
			log.Println("To: " + toGeneral[0])
			log.Println("Subject: " + subjectGeneral)
			log.Println("Body: " + bodyGeneral)
		}

		if data.IsComing && data.DoYouBringCake {
			toCoffee := []string{emailCoffee}
			subjectCoffee := resolveIsComing(data.IsComing) + " - Hochzeit - Kuchen"
			bodyCoffee := resolveIsComing(data.IsComing) + " von: " + data.Name +
				"\nKommt: " + resolveBool(data.IsComing) +
				"\n\nBringst du Kuchen mit: " + resolveBool(data.DoYouBringCake) +
				"\nKuchen: " + data.CakeFlavor +
				"\n\n\nKontaktinformation: " + data.ContactInformation

			msgCoffee := gomail.NewMessage()
			msgCoffee.SetHeader("From", from)
			msgCoffee.SetHeader("To", toCoffee[0])
			msgCoffee.SetHeader("Subject", subjectCoffee)
			msgCoffee.SetBody("text/plain", bodyCoffee)
			if !debug {
				if err := mailer.DialAndSend(msgCoffee); err != nil {
					log.Println(err)
					return c.Status(500).JSON(fiber.Map{"error": "Error sending cake email"})
				}
			} else {
				log.Println("Cake email:")
				log.Println("From: " + from)
				log.Println("To: " + toCoffee[0])
				log.Println("Subject: " + subjectCoffee)
				log.Println("Body: " + bodyCoffee)
			}
		}

		if data.IsComing && data.DoYouHaveContribution {
			toFestivities := []string{emailFestivities}
			subjectFestivities := resolveIsComing(data.IsComing) + " - Hochzeit - Beitrag"
			bodyFestivities := resolveIsComing(data.IsComing) + " von: " + data.Name +
				"\nKommt: " + resolveBool(data.IsComing) +
				"\n\nHast du einen Beitrag: " + resolveBool(data.DoYouHaveContribution) +
				"\nThema: " + data.Topic +
				"\nBenötigst du einen Projektor: " + resolveBool(data.NeedProjector) +
				"\nBenötigst du Musik: " + resolveBool(data.NeedMusic) +
				"\n\n\nKontaktinformation: " + data.ContactInformation

			msgFestivities := gomail.NewMessage()
			msgFestivities.SetHeader("From", from)
			msgFestivities.SetHeader("To", toFestivities[0])
			msgFestivities.SetHeader("Subject", subjectFestivities)
			msgFestivities.SetBody("text/plain", bodyFestivities)
			if !debug {
				if err := mailer.DialAndSend(msgFestivities); err != nil {
					log.Println(err)
					return c.Status(500).JSON(fiber.Map{"error": "Error sending contribution email"})
				}
			} else {
				log.Println("Contribution email:")
				log.Println("From: " + from)
				log.Println("To: " + toFestivities[0])
				log.Println("Subject: " + subjectFestivities)
				log.Println("Body: " + bodyFestivities)
			}
		}

		return c.JSON(fiber.Map{"message": "Emails sent successfully"})
	})

	log.Fatal(app.Listen(":3000"))
}

func resolveBool(value bool) string {
	if value {
		return "Ja"
	}
	return "Nein"

}

func resolveIsComing(value bool) string {
	if value {
		return "Zusage"
	}
	return "Absage"
}
