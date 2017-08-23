#[macro_use] extern crate winreg;
#[macro_use] extern crate rustler;
#[macro_use] extern crate rustler_codegen;
#[macro_use] extern crate lazy_static;

use rustler::{NifEnv, NifTerm, NifResult, NifEncoder};
use winreg::RegKey;
use winreg::enums::*;


mod atoms {
    rustler_atoms! {
        atom ok;
        //atom error;
        atom __true__ = "true";
        atom __false__ = "false";
    }
}

rustler_export_nifs! {
    "Elixir.Pragmatic.Windows",
    [("add", 2, add)],
    None
}

fn add<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let hklm = RegKey::predef(HKEY_LOCAL_MACHINE);
    let file_system_key = hklm.open_subkey_with_flags("SYSTEM\\CurrentControlSet\\Control\\FileSystem", KEY_READ).unwrap();
    let eight_dot_three_disabled: u32 = file_system_key.get_value("NtfsDisable8dot3NameCreation").unwrap();
    let eight_dot_three_disabled_bool = eight_dot_three_disabled == 1;
    let num1: i64 = try!(args[0].decode());
    let num2: i64 = try!(args[1].decode());

    if eight_dot_three_disabled_bool{
      Ok((atoms::ok(), atoms::__true__()).encode(env))
    }
    else{
      Ok((atoms::ok(), atoms::__false__()).encode(env))
    }

}
