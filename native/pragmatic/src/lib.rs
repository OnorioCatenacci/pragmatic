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
//        atom __true__ = "true";
//        atom __false__ = "false";
        atom ntfs_create_short_names = "ntfs_create_short_names";
        atom ntfs_never_create_short_names = "ntfs_never_create_short_names";
        atom ntfs_create_short_per_volume = "ntfs_create_short_per_volume";
        atom ntfs_create_short_only_on_system_volume = "ntfs_create_short_only_on_system_volume";
        atom e_cannot_determine_ntfs_setting="e_cannot_determine_ntfs_setting";
        atom error;
    }
}

rustler_export_nifs! {
    "Elixir.Pragmatic.Windows",
    [("add", 2, add),("check_short_names",2,check_short_names)],
    None
}

fn add<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let num1: i64 = try!(args[0].decode());
    let num2: i64 = try!(args[1].decode());

      Ok((atoms::ok(), num1 + num2).encode(env))
}

fn check_short_names<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let hklm = RegKey::predef(HKEY_LOCAL_MACHINE);
    let file_system_key = hklm.open_subkey_with_flags("SYSTEM\\CurrentControlSet\\Control\\FileSystem", KEY_READ).unwrap();
    let eight_dot_three_disabled: u32 = file_system_key.get_value("NtfsDisable8dot3NameCreation").unwrap();

    match eight_dot_three_disabled {
        0 => Ok((atoms::ok(), atoms::ntfs_create_short_names()).encode(env)),
        1 => Ok((atoms::ok(), atoms::ntfs_never_create_short_names()).encode(env)),
        2 => Ok((atoms::ok(), atoms::ntfs_create_short_per_volume()).encode(env)),
        3 => Ok((atoms::ok(), atoms::ntfs_create_short_only_on_system_volume ()).encode(env)),
        _ => Ok((atoms::error(),atoms::e_cannot_determine_ntfs_setting()).encode(env))
    }
}

