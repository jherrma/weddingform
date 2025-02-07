package models

type FormData struct {
	// general
	Name               string `json:"name"`
	IsComing           bool   `json:"isComing"`
	WhoIsComing        string `json:"whoIsComing"`
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
