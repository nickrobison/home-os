use capnp_rpc::pry;
use logs::{info, warn};
use tokio::sync::oneshot::Sender;

use crate::pinger_rpc::registrar_capnp::registration_callback;
use crate::pinger_rpc::registration_capnp::registration_response;
use crate::types::Promise;

pub struct RegistrationCallbackImpl {
    pub sender: Sender<String>,
}

impl registration_callback::Server for RegistrationCallbackImpl {
    fn callback(&mut self,
                params: capnp::capability::Params<registration_callback::callback_params::Owned>,
                _results: capnp::capability::Results<registration_callback::callback_results::Owned>,
    ) -> Promise<()> {
        info!("I have a response!");
        let params = pry!(params.get());
        let res = pry!(params.get_response());
        match pry!(res.which()) {
            registration_response::Success(_) => {
                warn!("Got success")
            }
            registration_response::Failure(msg) => {
                info!("Failed: {}", pry!(msg));
            }
        }
        Promise::ok(())
    }
}