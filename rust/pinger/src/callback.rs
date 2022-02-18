use capnp_rpc::pry;
use crossbeam::channel::Sender;
use logs::info;

use crate::pinger_rpc::registrar_capnp::registration_callback;
use crate::pinger_rpc::registration_capnp::registration_response;
use crate::pinger_rpc::services_capnp::service_resolver;
use crate::types::Promise;

pub struct RegistrationCallbackImpl {
    pub sender: Sender<Result<service_resolver::Client, capnp::Error>>,
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
        let mut resolve_request = resolver.resolve_request();
        let channel = self.sender.clone();
        return Promise::from_future(async move {
            let resolve_response = resolve_request.send().promise.await?;
            let services = resolve_response.get().unwrap().get_services().unwrap();
            let svc_count = services.len();
            info!("Resolver resolved {} services", svc_count);
            let pinger_svc = services.get(0);
            info!("I have a service named: {}", pinger_svc.get_name()?);

            // channel.send(Result::Err(capnp::Error::failed("So close!!!".to_string())))
            //     .map_err(|_| capnp::Error::failed("Unable to send msg".to_string()));
            return Result::Err(capnp::Error::failed("So close!".to_string()));
        });


        Promise::ok(())
    }
    // fn callback(&mut self,
    //             params: capnp::capability::Params<registration_callback::callback_params::Owned>,
    //             _results: capnp::capability::Results<registration_callback::callback_results::Owned>,
    // ) -> Promise<()> {
    //     info!("I have a response!");
    //     let params = pry!(params.get());
    //     let res = pry!(params.get_response());
    //     match pry!(res.which()) {
    //         registration_response::Success(resolver) => {
    //             info!("I have a resolver!");
    //             let mut resolve_request = pry!(resolver).resolve_request();
    //             let channel = self.sender.clone();
    //             return Promise::from_future(async move {
    //                 let resolve_response = resolve_request.send().promise.await?;
    //
    //                 info!("Resolver resolved");
    //
    //                 // channel.send(Result::Err(capnp::Error::failed("So close!!!".to_string())))
    //                 //     .map_err(|_| capnp::Error::failed("Unable to send msg".to_string()));
    //                 return Result::Err(capnp::Error::failed("So close!".to_string()));
    //             });
    //         }
    //         registration_response::Failure(msg) => {
    //             info!("Failed: {}", pry!(msg));
    //             let channel = self.sender.clone();
    //             channel.send(Result::Err(capnp::Error::failed(pry!(msg).to_string())))
    //                 .map_err(|_| capnp::Error::failed("Unable to send msg".to_string()));
    //             return Promise::err(capnp::Error::failed("Unable to register".to_string()));
    //         }
    //     }
    // }
}