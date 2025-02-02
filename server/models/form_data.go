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
	StartersOption1 string `json:"startersOption1"`
	StartersOption2 string `json:"startersOption2"`
	MainOption1     string `json:"mainOption1"`
	MainOption2     string `json:"mainOption2"`
	MainOption3     string `json:"mainOption3"`
	DessertOption1  string `json:"dessertOption1"`
	DessertOption2  string `json:"dessertOption2"`
}
