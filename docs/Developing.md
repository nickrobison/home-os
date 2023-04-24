# Developing HomeOS


## Go

Due to the fact that we have our Go packages in a sub-directory of the repo, the `gopls` integration with VS Code gets confused, so you'll probably need to add the `go` directory via `Add Directory to Current Workspace` in order for code completion to work correctly.

## Debugging Capnproto

A simple way to debug Capnproto implementations, is to connect via a Python client.
This allows for dynamic testing of the implementation in a much easier way than spinning up a separate service.

We provide a simple getting started notebook [here](../python/debugger/).

```python
jupyter notebook
```

