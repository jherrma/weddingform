package models

type ConfigContainer struct {
	UsernameCoffee      string
	SecretCoffee        string
	UsernameFestivities string
	SecretFestivities   string

	EmailRecipientGeneral       string
	EmailRecipientCoffee        string
	EmailRecipientContributions string

	SmtpHost     string
	SmtpPort     string
	SmtpUser     string
	SmtpPassword string

	Debug bool

	MongoUri   string
	Database   string
	Collection string
}
