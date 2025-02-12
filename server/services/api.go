package services

import (
	"fmt"
	"log"
	"strconv"
	"weddingform/server/models"

	"github.com/gofiber/fiber/v2"
	"gopkg.in/gomail.v2"
)

func NewApiService(configContainer *models.ConfigContainer, mongo *MongoDb) *ApiSerice {
	return &ApiSerice{
		configContainer: configContainer,
		mongo:           mongo,
	}
}

type ApiSerice struct {
	configContainer *models.ConfigContainer
	mongo           *MongoDb
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

	if err := a.mongo.InsertNewForm(&data); err != nil {
		log.Printf("Error inserting new form data %s", err.Error())
	}

	mailer, err := GetMailer(a.configContainer)
	if err != nil {
		log.Println(err)
		return c.Status(500).JSON(fiber.Map{"error": "Error sending email"})
	}

	sendMessageGeneral(a.configContainer, mailer, &data)
	sendMessageCoffe(a.configContainer, mailer, &data)
	sendMessageContributions(a.configContainer, mailer, &data)

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

func GetMailer(config *models.ConfigContainer) (*gomail.Dialer, error) {
	if config.Debug {
		return nil, nil
	}

	port, err := strconv.Atoi(config.SmtpPort)
	if err != nil {
		return nil, fmt.Errorf("invalid SMTP port")
	}

	mailer := gomail.NewDialer(config.SmtpHost, port, config.SmtpUser, config.SmtpPassword)
	mailer.SSL = false

	return mailer, nil
}

func getMessageGeneral(config *models.ConfigContainer, data *models.FormData) *gomail.Message {
	from := config.SmtpUser
	toGeneral := []string{config.EmailRecipientGeneral}
	subjectGeneral := resolveIsComing(data.IsComing) + " - Hochzeit - Allgemein und Mahlzeiten"
	bodyGeneral := resolveIsComing(data.IsComing) + " von: " + data.Name +
		"\nKommt: " + resolveBool(data.IsComing) +
		"\nWer kommt noch: " + data.WhoIsComing +
		"\n\nGerichte:\nSchwäbische Hochzeitssuppe: " + fmt.Sprint(data.HochzeitSuppe) +
		"\nBunter Beilagensalat: " + fmt.Sprint(data.Salat) +
		"\nRinderschmorbraten: " + fmt.Sprint(data.Rinderbraten) +
		"\nHähnchenbrust auf Kräuterkruste: " + fmt.Sprint(data.Huhn) +
		"\nGebackene Falafel: " + fmt.Sprint(data.Falafel) +
		"\nCreme brulee: " + fmt.Sprint(data.CremeBrule) +
		"\nMousse au Chocolat: " + fmt.Sprint(data.MousseAuChcolat) +
		"\n\nWas wir noch mitteilen wollen: " + data.Notes +
		"\n\n\nKontaktinformation: " + data.ContactInformation

	msgGeneral := gomail.NewMessage()
	msgGeneral.SetHeader("From", from)
	msgGeneral.SetHeader("To", toGeneral[0])
	msgGeneral.SetHeader("Subject", subjectGeneral)
	msgGeneral.SetBody("text/plain", bodyGeneral)

	if config.Debug {
		log.Println("General and meal email:")
		log.Println("From: " + from)
		log.Println("To: " + toGeneral[0])
		log.Println("Subject: " + subjectGeneral)
		log.Println("Body: " + bodyGeneral)
	}

	return msgGeneral
}

func sendMessageGeneral(config *models.ConfigContainer, mailer *gomail.Dialer, data *models.FormData) error {
	msgGeneral := getMessageGeneral(config, data)

	if config.Debug {
		return nil
	}

	if err := mailer.DialAndSend(msgGeneral); err != nil {
		log.Println(err)
		return err
	}

	return nil
}

func getMessageCoffee(config *models.ConfigContainer, data *models.FormData) *gomail.Message {
	from := config.SmtpUser
	toCoffee := []string{config.EmailRecipientCoffee}
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

	if config.Debug {
		log.Println("Cake email:")
		log.Println("From: " + from)
		log.Println("To: " + toCoffee[0])
		log.Println("Subject: " + subjectCoffee)
		log.Println("Body: " + bodyCoffee)
	}

	return msgCoffee
}

func sendMessageCoffe(config *models.ConfigContainer, mailer *gomail.Dialer, data *models.FormData) error {
	if !data.IsComing || !data.DoYouBringCake {
		return nil
	}

	msgCoffee := getMessageCoffee(config, data)

	if config.Debug {
		return nil
	}

	if err := mailer.DialAndSend(msgCoffee); err != nil {
		log.Println(err)
		return err
	}

	return nil
}

func getMessageContributions(config *models.ConfigContainer, data *models.FormData) *gomail.Message {
	from := config.SmtpUser
	toContributions := []string{config.EmailRecipientContributions}
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

	if config.Debug {
		log.Println("Contribution email:")
		log.Println("From: " + from)
		log.Println("To: " + toContributions[0])
		log.Println("Subject: " + subjectFestivities)
		log.Println("Body: " + bodyFestivities)
	}

	return msgFestivities
}

func sendMessageContributions(config *models.ConfigContainer, mailer *gomail.Dialer, data *models.FormData) error {
	if !data.IsComing || !data.DoYouHaveContribution {
		return nil
	}

	msgFestivities := getMessageContributions(config, data)

	if config.Debug {
		return nil
	}

	if err := mailer.DialAndSend(msgFestivities); err != nil {
		log.Println(err)
		return err
	}

	return nil
}
