// FRB_INTERNAL_GENERATOR: {"forbiddenDuplicatorModes": ["sync", "rustAsync", "sse", "sync sse", "rustAsync sse"]}
use crate::constant::{app_data_path, db_conn_pool};
use log::{debug, error, info};
use std::{collections::HashMap, fmt::Display};

#[derive(sqlx::FromRow, Debug)]
struct Test {
    id: i32,
    content: String,
}

pub async fn simple_use_async_spawn(arg: String) -> String {
    info!("simple_use_async_spawn: {}", arg);
    let test_records = sqlx::query_as::<_, Test>("select * from test")
        .fetch_all(db_conn_pool().await.unwrap())
        .await
        .unwrap();
    info!("test_records: {:?}", test_records);
    let resp = reqwest::get("https://httpbin.org/ip").await;
    let res = match resp {
        Ok(resp) => {
            let body = resp.json::<HashMap<String, String>>().await.unwrap();
            // let body = resp.text().await.unwrap();
            info!("body 3: {:?}", body);
            print!("log info body: {:?}", body);
            debug!("log info body: {:?}", body);
            info!("args : {}", arg);
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
