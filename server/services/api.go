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
			"emailContribution": a.configContainer.EmailRecipientContributions,
		})
	} else if data.Password == a.configContainer.SecretFestivities {
		return c.JSON(fiber.Map{
			"type":              1,
			"username":          a.configContainer.UsernameFestivities,
			"password":          a.configContainer.SecretFestivities,
			"emailCoffee":       a.configContainer.EmailRecipientCoffee,
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
		mailer = gomail.NewDialer(a.configContainer.SmtpHost, port, a.configContainer.SmtpUser, a.configContainer.SmtpPassword)
		mailer.SSL = false
	}

	from := a.configContainer.SmtpUser
	toGeneral := []string{a.configContainer.EmailRecipientGeneral}
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
	if !a.configContainer.Debug {
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
		toCoffee := []string{a.configContainer.EmailRecipientCoffee}
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
		if !a.configContainer.Debug {
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
		toContributions := []string{a.configContainer.EmailRecipientContributions}
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
		msgFestivities.SetHeader("To", toContributions[0])
		msgFestivities.SetHeader("Subject", subjectFestivities)
		msgFestivities.SetBody("text/plain", bodyFestivities)
		if !a.configContainer.Debug {
			if err := mailer.DialAndSend(msgFestivities); err != nil {
				log.Println(err)
				return c.Status(500).JSON(fiber.Map{"error": "Error sending contribution email"})
			}
		} else {
			log.Println("Contribution email:")
			log.Println("From: " + from)
			log.Println("To: " + toContributions[0])
			log.Println("Subject: " + subjectFestivities)
			log.Println("Body: " + bodyFestivities)
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
