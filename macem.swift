import Foundation
import Security

/**
    Export a list of identities to a .p12 file.

    - Parameter password: The password to use for protecting the export file.
    - Parameter targetPath: The path where to save the expor file.
    - Parameter identities: An array containing the identities to export.

    - Returns: errSecSuccess if succeeded, error code otherwise.
*/
func export(_ password: String, _ targetPath: String, _ identities: [SecIdentity]) -> OSStatus {
    let exportFlags = SecItemImportExportFlags.pemArmour

    var parameters = SecItemImportExportKeyParameters(
        version: UInt32(SEC_KEY_IMPORT_EXPORT_PARAMS_VERSION),
        flags: .noAccessControl,
        passphrase: Unmanaged.passRetained((password as CFString) as CFTypeRef),
        alertTitle: nil,
        alertPrompt: nil,
        accessRef: nil,
        keyUsage: nil,
        keyAttributes: nil
    )

    var dataOpt: CFData? = nil
    let status = SecItemExport(identities as CFArray, .formatPKCS12, exportFlags, &parameters, &dataOpt)

    if status == errSecSuccess {
        if let data = dataOpt as? Data {
            do {
                try data.write(to: URL(fileURLWithPath: targetPath))
            } catch {
                print("Error occured during save of file.")
            }
        }
    }

    return status
}

/**
    Retrieve all identities whose label starts with "Apple " from keychain.

    - Parameter identities: an array that will contain the matching identities.

    - Returns: errSecSuccess if succeeded, error code otherwise.
*/
func getAllIdentities(_ identities: inout [SecIdentity]) -> OSStatus {
    let query: [String: Any] = [
        kSecClass as String: kSecClassIdentity,
        kSecMatchLimit as String : kSecMatchLimitAll,
        kSecMatchSubjectStartsWith as String : "Apple ",
        kSecReturnRef as String: true,
    ]

    var _identities: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &_identities)

    if status == errSecSuccess {
        identities = _identities as! [SecIdentity]
    }

    return status
}

/**
    Parse cli arguments.

    - Parameter arguments: an array containing the cli arguments.
    
    - Returns a tuple containing the password and the target path. Variables may be empty.
*/
func parseCli(_ arguments: [String]) -> (String?, String?) {
    var password: String?
    var targetPath: String?

    for (index, element) in arguments.enumerated() {
        if index + 1 < arguments.count && element == "-P" {
            password = arguments[index + 1]
        }

        if index + 1 < arguments.count && element == "-o" {
            targetPath = arguments[index + 1]
        }
    }

    return (password, targetPath)
}

/**
    Print the program usage string.
*/
func usage() {
    print("Welcome to mac OS certificate manager (macem)")
    print("macem export all certificates and their private keys from keychain, allowing the export to be shared between hosts.")
    print("Usage:")
    print("    macem -P <exportPassword> -o <targetPath>")
    print("    with: ")
    print("        exportPassword: the password that protect the resulting .p12")
    print("        targetPath: the target file name")
}

let (password, targetPath) = parseCli(CommandLine.arguments)

if password == nil || targetPath == nil {
    usage()
    exit(1)
}

var identities: [SecIdentity] = []
var status = getAllIdentities(&identities)

if status != errSecSuccess {
    print("An error occured during getting of status, error code: \(status)") 
    exit(EXIT_FAILURE)
}

if identities.count == 0 {
    print("No identity to export. Skipping.")
}

status = export(password!, targetPath!, identities)

if status != errSecSuccess {
    print("An error occured during export, error code: \(status)")
}

exit(EXIT_FAILURE)
