package middleware

import (
	"context"
	"fmt"
	"github.com/go-chi/chi/middleware"
	"github.com/rs/zerolog"
	"net/http"
	"time"
)

// ContextKey defines a key to pull out of the given context object
type ContextKey struct {
	Name string
}

// String - stringer interface
func (k *ContextKey) String() string {
	return fmt.Sprintf("Middlware context key: %s", k.Name)
}

var (
	// LoggerKey is the key to use to pull a logger out of the given context object
	LoggerKey = &ContextKey{"logger"}
)

func NewStructuredLogger(logger *zerolog.Logger) func(next http.Handler) http.Handler {
	return middleware.RequestLogger(&StructuredLogger{logger})
}

type StructuredLogger struct {
	Logger *zerolog.Logger
}

func (l *StructuredLogger) NewLogEntry(r *http.Request) middleware.LogEntry {

	lc := l.Logger.With()

	if reqID := middleware.GetReqID(r.Context()); reqID != "" {
		lc.Str("request_id", reqID)
	}

	lc.Str("remote_ip", r.RemoteAddr)

	scheme := "http"
	if r.TLS != nil {
		scheme = "https"
	}

	lc.Str("uri", fmt.Sprintf("%s://%s%s", scheme, r.Host, r.RequestURI))

	entry := &StructuredLogEntry{}
	logger := lc.Logger()
	entry.Event = logger.Info()
	return entry
}

type StructuredLogEntry struct {
	Event *zerolog.Event
}

func (e *StructuredLogEntry) Write(status, bytes int, header http.Header, elapsed time.Duration, extra interface{}) {
	e.Event.Dur("elapsed", elapsed).Int("status", status).Int("resp_length", bytes)

	e.Event.Msg("request complete")
}

func (e *StructuredLogEntry) Panic(v interface{}, stack []byte) {
	e.Event.Stack().Msg(fmt.Sprintf("%+v", v))
}

func ContextLogger(logger *zerolog.Logger) func(next http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		fn := func(w http.ResponseWriter, r *http.Request) {
			ctx := r.Context()
			ctx = context.WithValue(ctx, LoggerKey, logger)
			next.ServeHTTP(w, r.WithContext(ctx))
		}

		return http.HandlerFunc(fn)
	}
}

func GetLogger(r *http.Request) *zerolog.Logger {
	return r.Context().Value(LoggerKey).(*zerolog.Logger)
}
