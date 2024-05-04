// FRB_INTERNAL_GENERATOR: {"forbiddenDuplicatorModes": ["sync", "rustAsync", "sse", "sync sse", "rustAsync sse"]}
use log::{debug, error, info};
use std::collections::HashMap;

pub async fn simple_use_async_spawn(arg: String) -> String {
    // ref demo in https://docs.rs/tokio/latest/tokio/task/fn.spawn.html
    // let handle = flutter_rust_bridge::spawn(async move { arg.repeat(2) });
    let resp = reqwest::get("https://httpbin.org/ip").await;
    let res = match resp {
        Ok(resp) => {
            let body = resp.json::<HashMap<String, String>>().await.unwrap();
            // let body = resp.text().await.unwrap();
            info!("body 3: {:?}", body);
            print!("log info body: {:?}", body);
            debug!("log info body: {:?}", body);
            let origin = body.get("origin").unwrap().to_string();
            origin
        }
        Err(e) => {
            error!("error: {:?}", e);
            "error".to_string()
        }
    };
    // .json::<HashMap<String, String>>()
    // .await?;
    res
}
