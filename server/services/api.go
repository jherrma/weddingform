package services

import (
	"log"
	"strconv"
	"weddingform/server/models"

	"github.com/gofiber/fiber/v2"
	"gopkg.in/gomail.v2"
)

func NewApiService(configContainer *models.ConfigContainer) *ApiSerice {
	return &ApiSerice{
		configContainer: configContainer,
	}
}

type ApiSerice struct {
	configContainer *models.ConfigContainer
}

func (a *ApiSerice) ValidatePassword(c *fiber.Ctx) error {
	var data models.PasswordData
	if err := c.BodyParser(&data); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "Cannot parse JSON"})
	}

	if data.Password == a.configContainer.SecretCoffee {
		return c.JSON(fiber.Map{
			"type":              0,
			"username":          a.configContainer.UsernameCoffee,
			"password":          a.configContainer.SecretCoffee,
			"emailCoffee":       a.configContainer.EmailRecipientCoffee,
			"emailRide":         a.configContainer.EmailRecipientRide,
			"emailContribution": a.configContainer.EmailRecipientContributions,
		})
	} else if data.Password == a.configContainer.SecretFestivities {
		return c.JSON(fiber.Map{
			"type":              1,
			"username":          a.configContainer.UsernameFestivities,
			"password":          a.configContainer.SecretFestivities,
			"emailCoffee":       a.configContainer.EmailRecipientCoffee,
			"emailRide":         a.configContainer.EmailRecipientRide,
			"emailContribution": a.configContainer.EmailRecipientContributions,
		})
	} else {
		return c.Status(401).JSON(fiber.Map{
			"error": "Unauthorized",
		})
	}
}

func (a *ApiSerice) GetFormData(c *fiber.Ctx) error {
	var data models.FormData
	if err := c.BodyParser(&data); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "Cannot parse JSON"})
	}

	var mailer *gomail.Dialer = nil

	if !a.configContainer.Debug {
		port, err := strconv.Atoi(a.configContainer.SmtpPort)
		if err != nil {
			log.Println("Invalid SMTP port")
			return c.Status(500).JSON(fiber.Map{"error": "Invalid SMTP port"})
		}

		mailer := gomail.NewDialer(a.configContainer.SmtpHost, port, a.configContainer.SmtpUser, a.configContainer.SmtpPassword)
		mailer.SSL = false
	}

	from := a.configContainer.SmtpUser
	toGeneral := []string{a.configContainer.EmailRecipientGeneral}
	subjectGeneral := resolveIsComing(data.IsComing) + " - Hochzeit - Allgemein und Mahlzeiten"
	bodyGeneral := resolveIsComing(data.IsComing) + " von: " + data.Name +
		"\nKommt: " + resolveBool(data.IsComing) +
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
	if !a.configContainer.Debug {
		if err := mailer.DialAndSend(msgGeneral); err != nil {
			log.Println(err.Error())
			return c.Status(500).JSON(fiber.Map{"error": "Error sending general and meal email"})
		}
	} else {
		log.Println("General email: " + bodyGeneral)
	}

	if data.IsComing && (data.DoYouBringCake || data.DoYouBringSnacks) {
		toCoffee := []string{a.configContainer.EmailRecipientCoffee}
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
		if !a.configContainer.Debug {
			if err := mailer.DialAndSend(msgCoffee); err != nil {
				log.Println(err)
				return c.Status(500).JSON(fiber.Map{"error": "Error sending cake email"})
			}
		} else {
			log.Println("Coffee email: " + bodyCoffee)
		}
	}

	if data.IsComing && data.DoYouHaveContribution {
		toFestivities := []string{a.configContainer.EmailRecipientContributions}
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
		if !a.configContainer.Debug {
			if err := mailer.DialAndSend(msgFestivities); err != nil {
				log.Println(err)
				return c.Status(500).JSON(fiber.Map{"error": "Error sending contribution email"})
			}
		} else {
			log.Println("Festivities email: " + bodyFestivities)
		}
	}

	if data.RideOption != 0 {
		toRide := []string{a.configContainer.EmailRecipientRide}
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

		if !a.configContainer.Debug {
			if err := mailer.DialAndSend(msgRide); err != nil {
				log.Println(err)
				return c.Status(500).JSON(fiber.Map{"error": "Error sending ride email"})
			}
		} else {
			log.Println("Ride email: " + bodyRide)
		}
	}

	return c.JSON(fiber.Map{"message": "Emails sent successfully"})

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
