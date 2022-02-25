use capnp_rpc::pry;
use crossbeam::channel::Sender;
use logs::info;

use protocols_rs::protocols::registration_capnp::registration_callback;
use protocols_rs::protocols::services_capnp::{ping, service};

use crate::types::Promise;

pub struct RegistrationCallbackImpl {
    pub sender: Sender<Result<ping::Client, capnp::Error>>,
}

impl registration_callback::Server for RegistrationCallbackImpl {
    fn success(&mut self,
               params: capnp::capability::Params<registration_callback::success_params::Owned>,
               _results: capnp::capability::Results<registration_callback::success_results::Owned>,
    ) -> Promise<()> {
        info!("I have success");
        let params = pry!(params.get());
        let resolver = pry!(params.get_resolver());
        info!("I have a resolver!");
        let resolve_request = resolver.resolve_request();
        let channel = self.sender.clone();
        return Promise::from_future(async move {
            let resolve_response = resolve_request.send().promise.await?;
            let resolve_response = resolve_response.get()?;
            let services = resolve_response.get_services()?;
            let svc_count = services.len();
            info!("Resolver resolved {} services", svc_count);
            let pinger_svc = services.get(0);
            info!("I have a service named: {}", pinger_svc.get_name()?);


            // Get the pinger
            return match pinger_svc.which()? {
                service::Ping(pinger) => {
                    channel.send(Result::Ok(pinger?))
                        .map_err(|_| capnp::Error::failed("Unable to send msg".to_string()))
                }
                service::Metrics(_) => {
                    channel.send(Result::Err(capnp::Error::failed("Sorry, wrong metric type".to_string())))
                        .map_err(|_| capnp::Error::failed("Unable to send msg".to_string()))
                }
            };
        });
    }
}
