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
	NumberOfPeople     int    `json:"numberOfPeople"`
	ContactInformation string `json:"contactInformation"`
	Allergies          string `json:"allergies"`
	IsVegetarian       bool   `json:"isVegetarian"`
	IsVegan            bool   `json:"isVegan"`
	Notes              string `json:"notes"`

	// contribution
	DoYouHaveContribution bool   `json:"doYouHaveContribution"`
	Topic                 string `json:"topic"`
	NeedProjector         bool   `json:"needProjector"`
	NeedMusic             bool   `json:"needMusic"`
	ContributionDuration  int    `json:"contributionDuration"`

	// cake and snacks
	DoYouBringCake   bool   `json:"doYouBringCake"`
	CakeFlavor       string `json:"cakeFlavor"`
	DoYouBringSnacks bool   `json:"doYouBringSnacks"`
	SnacksFlavor     string `json:"snacksFlavor"`

	// rides
	RideOption int `json:"rideOption"`
	NeedRide   int `json:"needRide"`
	OfferRide  int `json:"offerRide"`
}

type PasswordData struct {
	Password string `json:"password"`
}

const (
	EMAIL_RECIPIENT_GENERAL     = "EMAIL_RECIPIENT_GENERAL"
	EMAIL_RECIPIENT_COFFEE      = "EMAIL_RECIPIENT_COFFEE"
	EMAIL_RECIPIENT_FESTIVITIES = "EMAIL_RECIPIENT_FESTIVITIES"
	EMAIL_RIDE                  = "EMAIL_RIDE"
	USER_COFFEE                 = "USER_COFFEE"
	USER_FESTIVITIES            = "USER_FESTIVITIES"
	SECRET_COFFEE               = "SECRET_COFFEE"
	SECRET_FESTIVITIES          = "SECRET_FESTIVITIES"
	SMTP_HOST                   = "SMTP_HOST"
	SMTP_PORT                   = "SMTP_PORT"
	SMTP_USER                   = "SMTP_USER"
	SMTP_PASSWORD               = "SMTP_PASSWORD"
	DEBUG                       = "DEBUG"
)

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Println("No .env file found")
	}

	smtpHost := os.Getenv(SMTP_HOST)
	smtpPort := os.Getenv(SMTP_PORT)
	smtpUser := os.Getenv(SMTP_USER)
	smtpPassword := os.Getenv(SMTP_PASSWORD)

	secretCoffee := os.Getenv(SECRET_COFFEE)
	secretFestivities := os.Getenv(SECRET_FESTIVITIES)

	userCoffee := os.Getenv(USER_COFFEE)
	userFestivities := os.Getenv(USER_FESTIVITIES)

	debugString := os.Getenv(DEBUG)
	debug, err := strconv.ParseBool(debugString)
	if err != nil {
		debug = true
	}

	if debug {
		log.Println("Debug mode is enabled")
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
				"type":     0,
				"username": userCoffee,
				"password": secretCoffee,
			})
		} else if data.Password == secretFestivities {
			return c.JSON(fiber.Map{
				"type":     1,
				"username": userFestivities,
				"password": secretFestivities,
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
			userCoffee:      secretCoffee,
			userFestivities: secretFestivities,
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

			mailer := gomail.NewDialer(smtpHost, port, smtpUser, smtpPassword)
			mailer.SSL = false
		}

		from := smtpUser
		toGeneral := []string{os.Getenv(EMAIL_RECIPIENT_GENERAL)}
		subjectGeneral := resolveIsComing(data.IsComing) + " - Hochzeit - Allgemein und Mahlzeiten"
		bodyGeneral := resolveIsComing(data.IsComing) + " von: " + data.Name +
			"\nKommt: " + resolveBool(data.IsComing) +
			"\n\nAnzahl der Personen: " + strconv.Itoa(data.NumberOfPeople) +
			"\nWer kommt: " + data.WhoIsComing +
			"\n\nAllergien: " + data.Allergies +
			"\nVegetarisch: " + resolveBool(data.IsVegetarian) +
			"\nVegan: " + resolveBool(data.IsVegan) +
			"\nDer Gast möchte noch etwas mitteilen: " + data.Notes +
			"\n\nKontaktinformation: " + data.ContactInformation

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
			log.Println("General email: " + bodyGeneral)
		}

		if data.IsComing && (data.DoYouBringCake || data.DoYouBringSnacks) {
			toCoffee := []string{os.Getenv(EMAIL_RECIPIENT_COFFEE)}
			subjectCoffee := resolveIsComing(data.IsComing) + " - Hochzeit - Kuchen"
			bodyCoffee := resolveIsComing(data.IsComing) + " von: " + data.Name +
				"\nKommt: " + resolveBool(data.IsComing) +
				"\n\nBringst du Kuchen mit: " + resolveBool(data.DoYouBringCake) +
				"\nKuchen: " + data.CakeFlavor +
				"\n\nBringst du Snacks mit: " + resolveBool(data.DoYouBringSnacks) +
				"\nSnacks: " + data.SnacksFlavor +
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
				log.Println("Coffee email: " + bodyCoffee)
			}
		}

		if data.IsComing && data.DoYouHaveContribution {
			toFestivities := []string{os.Getenv(EMAIL_RECIPIENT_FESTIVITIES)}
			subjectFestivities := resolveIsComing(data.IsComing) + " - Hochzeit - Beitrag"
			bodyFestivities := resolveIsComing(data.IsComing) + " von: " + data.Name +
				"\nKommt: " + resolveBool(data.IsComing) +
				"\n\nHast du einen Beitrag: " + resolveBool(data.DoYouHaveContribution) +
				"\nThema: " + data.Topic +
				"\nBenötigst du einen Projektor: " + resolveBool(data.NeedProjector) +
				"\nBenötigst du Musik: " + resolveBool(data.NeedMusic) +
				"\nDauer: " + strconv.Itoa(data.ContributionDuration) + " Minuten" +
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
				log.Println("Festivities email: " + bodyFestivities)
			}
		}

		if data.RideOption != 0 {
			toRide := []string{os.Getenv(EMAIL_RIDE)}
			subjectRide := "Mitfahrgelegenheit - " + resolveRides(data.RideOption)
			bodyRide := resolveIsComing(data.IsComing) + " von: " + data.Name +
				"\nOption: " + resolveRides(data.RideOption) +
				"\n" + resolveSeats(data.RideOption, data.NeedRide) +
				"\n\nKontaktinformation: " + data.ContactInformation

			msgRide := gomail.NewMessage()
			msgRide.SetHeader("From", from)
			msgRide.SetHeader("To", toRide[0])
			msgRide.SetHeader("Subject", subjectRide)
			msgRide.SetBody("text/plain", bodyRide)

			if !debug {
				if err := mailer.DialAndSend(msgRide); err != nil {
					log.Println(err)
					return c.Status(500).JSON(fiber.Map{"error": "Error sending ride email"})
				}
			} else {
				log.Println("Ride email: " + bodyRide)
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

func resolveRides(value int) string {
	if value == 0 {
		return "Ich fahre öffentlich"
	} else if value == 1 {
		return "Ich BENÖTIGE eine Mitfahrgelegenheit"
	} else {
		return "Ich BIETE eine Mitfahrgelegenheit"
	}
}

func resolveSeats(rideOption int, seats int) string {
	if rideOption == 0 {
		return ""
	} else if rideOption == 1 {
		return "Plätze benötigt: " + strconv.Itoa(seats)
	} else {
		return "Plätze angeboten: " + strconv.Itoa(seats)
	}
}
