use crate::constant::{app_data_path, run_migrations};
#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    info!("greet: {}", name);
    format!("Hello, {name}!")
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

pub async fn init_lib(path: String) {
    info!("init_lib: {}", path);
    //set work dir
    app_data_path(path);
    // run database migrations
    run_migrations().await.unwrap();
}
// #[flutter_rust_bridge::frb(init)]
// pub fn set_desktop_logger() {
//     // print!("init env logger for desktop platforms");
//     #[cfg(target_os = "macos")]
//     flutter_logger::init(sink, filter);
// }
// #[cfg(target_os = "macos")]
flutter_logger::flutter_logger_init!();
