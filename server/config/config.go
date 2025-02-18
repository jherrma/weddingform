package config

import (
	"log"
	"os"
	"strconv"
	"weddingform/server/models"

	"github.com/joho/godotenv"
)

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
	MONGO_URI                   = "MONGODB_URI"
	MONGO_DATBASE               = "MONGODB_DATABASE"
	MONGO_COLLECTION            = "MONGODB_COLLECTION"
)

var (
	config *models.ConfigContainer
)

func GetConfig() *models.ConfigContainer {
	if config == nil {
		config = loadConfig()
	}

	return config

}

func loadConfig() *models.ConfigContainer {
	err := godotenv.Load()
	if err != nil {
		log.Println("No .env file found")
	}

	debugString := os.Getenv("DEBUG")
	debug, err := strconv.ParseBool(debugString)
	if err != nil {
		debug = true
	}

	if debug {
		log.Println("Debug enabled")
	}

	return &models.ConfigContainer{
		UsernameCoffee:              os.Getenv(USER_COFFEE),
		UsernameFestivities:         os.Getenv(USER_FESTIVITIES),
		SecretCoffee:                os.Getenv(SECRET_COFFEE),
		SecretFestivities:           os.Getenv(SECRET_FESTIVITIES),
		SmtpHost:                    os.Getenv(SMTP_HOST),
		SmtpPort:                    os.Getenv(SMTP_PORT),
		SmtpUser:                    os.Getenv(SMTP_USER),
		SmtpPassword:                os.Getenv(SMTP_PASSWORD),
		EmailRecipientGeneral:       os.Getenv(EMAIL_RECIPIENT_GENERAL),
		EmailRecipientCoffee:        os.Getenv(EMAIL_RECIPIENT_COFFEE),
		EmailRecipientContributions: os.Getenv(EMAIL_RECIPIENT_FESTIVITIES),
		Debug:                       debug,
		MongoUri:                    os.Getenv(MONGO_URI),
		Database:                    os.Getenv(MONGO_DATBASE),
		Collection:                  os.Getenv(MONGO_COLLECTION),
	}
}
