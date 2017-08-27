#[macro_use] extern crate winreg;
//#[macro_use] extern crate kernel32;
//#[macro_use] extern crate winapi;
#[macro_use] extern crate rustler;
#[macro_use] extern crate rustler_codegen;
#[macro_use] extern crate lazy_static;

use rustler::{NifEnv, NifTerm, NifResult, NifEncoder};
use winreg::RegKey;
use winreg::enums::*;
/*use winapi::{LPCWSTR,DWORD,LPWSTR};
use kernel32::GetShortPathNameW; */


mod atoms {
    rustler_atoms! {
        atom ok;
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
    [
        ("check_short_name_support", 0, check_short_name_support),
    ],
    None
}

/* fn add<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let num1: i64 = try!(args[0].decode());
    let num2: i64 = try!(args[1].decode());

      Ok((atoms::ok(), num1 + num2).encode(env))
} */

fn check_short_name_support<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let hklm = RegKey::predef(HKEY_LOCAL_MACHINE);
    let file_system_key = hklm.open_subkey_with_flags("SYSTEM\\CurrentControlSet\\Control\\FileSystem", KEY_READ).unwrap();
    let eight_dot_three_disabled: u32 = file_system_key.get_value("NtfsDisable8dot3NameCreation").unwrap();

    let (status_atom, message_atom) = match eight_dot_three_disabled
    {
        0 => (atoms::ok(), atoms::ntfs_create_short_names()),
        1 => (atoms::ok(), atoms::ntfs_never_create_short_names()),
        2 => (atoms::ok(), atoms::ntfs_create_short_per_volume()),
        3 => (atoms::ok(), atoms::ntfs_create_short_only_on_system_volume ()),
        _ => (atoms::error(), atoms::e_cannot_determine_ntfs_setting())
    };

    Ok((status_atom, message_atom).encode(env))
}

/*fn get_short_path_name<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    use std::ffi::OsStr;
    use std::os::windows::ffi::OsStrExt;
    use std::iter::once;

    let long_path_name: Vec<u16> = OsStr::new(try!(args[0].decode())).encode_wide().chain(once(0)).collect();
    let short_path_name: LPWSTR = new LPWSTR;
//    let long_path_name:String = try!(args[0].decode());
//    let short_path_name:LPTSTR;
    let mut length_short_path_name:DWORD = 0;
    unsafe{
        let len = GetShortPathNameW(long_path_name.as_ptr(), short_path_name, length_short_path_name);


        Ok((atoms::ok(), String::from_utf16(std::slice::from_raw_parts(short_path_name,length_short_path_name as usize)).unwrap()).encode(env))
    }
}*/
