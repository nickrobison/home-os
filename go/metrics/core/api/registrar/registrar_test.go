package registrar

import (
	"bytes"
	"github.com/go-chi/chi"
	cm "github.com/go-chi/chi/middleware"
	"github.com/nickrobison/home-os/middleware"
	"github.com/nickrobison/home-os/protocols"
	"github.com/rs/zerolog/log"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	capnp "zombiezen.com/go/capnproto2"
)

var (
	respReq *httptest.ResponseRecorder
	r       *chi.Mux
)

func setup() {
	r = chi.NewRouter()
	r.Use(cm.Recoverer)
	r.Use(middleware.ContextLogger(&log.Logger))
	r.Post("/", SubmitRegistration)

	respReq = httptest.NewRecorder()
}

func TestEmptyRequest(t *testing.T) {
	setup()
	sr := strings.NewReader("")
	req, err := http.NewRequest("POST", "/", sr)
	if err != nil {
		t.Fatal("Could not create")
	}

	r.ServeHTTP(respReq, req)

	if respReq.Code != http.StatusBadRequest {
		t.Fatal("Server error: Returned ", respReq.Code, " instead of ", http.StatusBadRequest)
	}
}

func TestSimpleRequest(t *testing.T) {
	setup()

	msg, seg, err := capnp.NewMessage(capnp.SingleSegment(nil))
	if err != nil {
		t.Fatal("Unable to create segment")
	}

	regReq, err := protocols.NewRootRegistrationRequest(seg)
	if err != nil {
		t.Fatal("Unble to create registratin request")
	}

	regReq.SetName("test-name")
	regReq.SetCallback("http://test.local")

	buf, err := msg.Marshal()
	if err != nil {
		t.Fatal("Cannot marshall message")
	}

	req, err := http.NewRequest("POST", "/", bytes.NewReader(buf))
	if err != nil {
		t.Fatal("Could not create")
	}

	r.ServeHTTP(respReq, req)

	if respReq.Code != http.StatusAccepted {
		t.Fatal("Server error: Returned ", respReq.Code, " instead of ", http.StatusAccepted)
	}
}
