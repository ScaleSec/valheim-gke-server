package interactions

import (
	"bytes"
	"crypto/ed25519"
	"encoding/json"
	"net/http"
	"os"

	"github.com/bsdlp/discord-interactions-go/interactions"
	log "github.com/sirupsen/logrus"
)

var (
	discordPubkey, discordPubkeyPresent = os.LookupEnv("DISCORD_PUBLIC_KEY")
)

func init() {
	if !discordPubkeyPresent {
		log.Fatal("Discord public key is unset")
	}
}

func Interactions(w http.ResponseWriter, r *http.Request) {
	verified := interactions.Verify(r, ed25519.PublicKey(discordPubkey))
	if !verified {
		http.Error(w, "signature mismatch", http.StatusUnauthorized)
		return
	}

	defer r.Body.Close()
	var data interactions.Data
	err := json.NewDecoder(r.Body).Decode(&data)
	if err != nil {
		// handle error
	}

	// respond to ping
	if data.Type == interactions.Ping {
		_, err := w.Write([]byte(`{"type":1}`))
		if err != nil {
			// handle error
		}
		return
	}

	// handle command
	response := &interactions.InteractionResponse{
		Type: interactions.ChannelMessage,
		Data: &interactions.InteractionApplicationCommandCallbackData{
			Content: "got your message kid",
		},
	}

	var responsePayload bytes.Buffer
	err = json.NewEncoder(&responsePayload).Encode(response)
	if err != nil {
		// handle error
	}

	_, err = http.Post(data.ResponseURL(), "application/json", &responsePayload)
	if err != nil {
		// handle err
	}
}
