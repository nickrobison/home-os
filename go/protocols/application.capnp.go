// Code generated by capnpc-go. DO NOT EDIT.

package protocols

import (
	capnp "capnproto.org/go/capnp/v3"
	text "capnproto.org/go/capnp/v3/encoding/text"
	schemas "capnproto.org/go/capnp/v3/schemas"
)

type Application capnp.Struct

// Application_TypeID is the unique identifier for the type Application.
const Application_TypeID = 0xe961ebf441207274

func NewApplication(s *capnp.Segment) (Application, error) {
	st, err := capnp.NewStruct(s, capnp.ObjectSize{DataSize: 0, PointerCount: 4})
	return Application(st), err
}

func NewRootApplication(s *capnp.Segment) (Application, error) {
	st, err := capnp.NewRootStruct(s, capnp.ObjectSize{DataSize: 0, PointerCount: 4})
	return Application(st), err
}

func ReadRootApplication(msg *capnp.Message) (Application, error) {
	root, err := msg.Root()
	return Application(root.Struct()), err
}

func (s Application) String() string {
	str, _ := text.Marshal(0xe961ebf441207274, capnp.Struct(s))
	return str
}

func (s Application) EncodeAsPtr(seg *capnp.Segment) capnp.Ptr {
	return capnp.Struct(s).EncodeAsPtr(seg)
}

func (Application) DecodeFromPtr(p capnp.Ptr) Application {
	return Application(capnp.Struct{}.DecodeFromPtr(p))
}

func (s Application) ToPtr() capnp.Ptr {
	return capnp.Struct(s).ToPtr()
}
func (s Application) IsValid() bool {
	return capnp.Struct(s).IsValid()
}

func (s Application) Message() *capnp.Message {
	return capnp.Struct(s).Message()
}

func (s Application) Segment() *capnp.Segment {
	return capnp.Struct(s).Segment()
}
func (s Application) Name() (string, error) {
	p, err := capnp.Struct(s).Ptr(0)
	return p.Text(), err
}

func (s Application) HasName() bool {
	return capnp.Struct(s).HasPtr(0)
}

func (s Application) NameBytes() ([]byte, error) {
	p, err := capnp.Struct(s).Ptr(0)
	return p.TextBytes(), err
}

func (s Application) SetName(v string) error {
	return capnp.Struct(s).SetText(0, v)
}

func (s Application) Description() (string, error) {
	p, err := capnp.Struct(s).Ptr(1)
	return p.Text(), err
}

func (s Application) HasDescription() bool {
	return capnp.Struct(s).HasPtr(1)
}

func (s Application) DescriptionBytes() ([]byte, error) {
	p, err := capnp.Struct(s).Ptr(1)
	return p.TextBytes(), err
}

func (s Application) SetDescription(v string) error {
	return capnp.Struct(s).SetText(1, v)
}

func (s Application) Consumes() (Service_List, error) {
	p, err := capnp.Struct(s).Ptr(2)
	return Service_List(p.List()), err
}

func (s Application) HasConsumes() bool {
	return capnp.Struct(s).HasPtr(2)
}

func (s Application) SetConsumes(v Service_List) error {
	return capnp.Struct(s).SetPtr(2, v.ToPtr())
}

// NewConsumes sets the consumes field to a newly
// allocated Service_List, preferring placement in s's segment.
func (s Application) NewConsumes(n int32) (Service_List, error) {
	l, err := NewService_List(capnp.Struct(s).Segment(), n)
	if err != nil {
		return Service_List{}, err
	}
	err = capnp.Struct(s).SetPtr(2, l.ToPtr())
	return l, err
}
func (s Application) Produces() (Service_List, error) {
	p, err := capnp.Struct(s).Ptr(3)
	return Service_List(p.List()), err
}

func (s Application) HasProduces() bool {
	return capnp.Struct(s).HasPtr(3)
}

func (s Application) SetProduces(v Service_List) error {
	return capnp.Struct(s).SetPtr(3, v.ToPtr())
}

// NewProduces sets the produces field to a newly
// allocated Service_List, preferring placement in s's segment.
func (s Application) NewProduces(n int32) (Service_List, error) {
	l, err := NewService_List(capnp.Struct(s).Segment(), n)
	if err != nil {
		return Service_List{}, err
	}
	err = capnp.Struct(s).SetPtr(3, l.ToPtr())
	return l, err
}

// Application_List is a list of Application.
type Application_List = capnp.StructList[Application]

// NewApplication creates a new list of Application.
func NewApplication_List(s *capnp.Segment, sz int32) (Application_List, error) {
	l, err := capnp.NewCompositeList(s, capnp.ObjectSize{DataSize: 0, PointerCount: 4}, sz)
	return capnp.StructList[Application](l), err
}

// Application_Future is a wrapper for a Application promised by a client call.
type Application_Future struct{ *capnp.Future }

func (f Application_Future) Struct() (Application, error) {
	p, err := f.Future.Ptr()
	return Application(p.Struct()), err
}

const schema_e5fec9f03b35e1f2 = "x\xda|\xca\xb1J\xc3@\x1c\xc7\xf1\xdf\xef\xfei\x8b" +
	"\xd0j\xcffq\xd2\xd9At\x10A\x17\xbb\x898\xf4" +
	"6\x07\x973\x09\x18h.G\x92n\x8e\x0a\xba\xf8\x0c" +
	"n\xbe\x84/\xe0c8\x88\x88\x8b\x94\xce=\x89\x83c" +
	"\xb7/\x1f\xbe\xfb[<\x8d\x0e\x06G](s\xd6\xe9" +
	"\x86\xa6\xda\x19/\xbe\xed\x17\xf4&\xc3\xfc\xfd\xf0\xe4\xe7" +
	"m\xf9\x81N\xd4\x03F\x94\xf9h m\xad\xc9'^" +
	"\x83\xf5~\x9a'\xb6Qy\xe9\xf6\x12\xeb\x9d?\x1e\xff" +
	"\xd1\xb6m\xf2\xd2MH3\x94\x08\x88\x08h\xbb\x0b\x98" +
	"+\xa1\xb9Q\xd4d\xcc\x16\xb3k\xc0\xa4B\xe3\x15\xb5" +
	"R1\x15\xa0\x8bs\xc0L\x85\xe6AQ\x8b\xc4\x14@" +
	"\xdf\xb7x'4\xcf\x8a\x1b\xce\x16\x19\xfbP\xec\x83!" +
	"\xcd\xea\xa4\xca}\x83^^\xba\x7fMJW\xcf\x8a\xac" +
	"\x06\xc0up\"\xe40\\,\x1f_.\x17\xb7O\x00" +
	"[\x0c\xbe*\xd3Y\xb2z\xfa\x0d\x00\x00\xff\xffje" +
	"E\x89"

func RegisterSchema(reg *schemas.Registry) {
	reg.Register(&schemas.Schema{
		String: schema_e5fec9f03b35e1f2,
		Nodes: []uint64{
			0xe961ebf441207274,
		},
		Compressed: true,
	})
}