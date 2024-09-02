module logistics_platform::utils {
    use std::debug;
    use std::string::{utf8};

    public fun debug_str(byte_message: &vector<u8>) {
        let string_message = utf8(*byte_message);
        debug::print(&string_message);
    }
}
