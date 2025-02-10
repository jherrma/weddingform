package models

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
	HochzeitSuppe   int `json:"startersOption1"`
	Salat           int `json:"startersOption2"`
	Rinderbraten    int `json:"mainOption1"`
	Huhn            int `json:"mainOption2"`
	Falafel         int `json:"mainOption3"`
	CremeBrule      int `json:"dessertOption1"`
	MousseAuChcolat int `json:"dessertOption2"`
}
