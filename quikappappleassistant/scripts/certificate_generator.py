#!/usr/bin/env python3
"""
Certificate Generator for QuikApp Support Assistant
This script handles CSR generation, certificate creation, and P12 export.
"""

import os
import sys
import json
import argparse
from datetime import datetime
from OpenSSL import crypto

def generate_csr(common_name, organization, organizational_unit, country, state, locality, email, key_path, csr_path):
    """Generate a Certificate Signing Request (CSR) and private key."""
    try:
        # Generate private key
        key = crypto.PKey()
        key.generate_key(crypto.TYPE_RSA, 2048)
        
        # Save private key
        with open(key_path, 'wb') as f:
            f.write(crypto.dump_privatekey(crypto.FILETYPE_PEM, key))
        
        # Create CSR
        req = crypto.X509Req()
        req.get_subject().CN = common_name
        req.get_subject().O = organization
        req.get_subject().OU = organizational_unit
        req.get_subject().C = country
        req.get_subject().ST = state
        req.get_subject().L = locality
        req.get_subject().emailAddress = email
        
        req.set_pubkey(key)
        req.sign(key, 'sha256')
        
        # Save CSR
        with open(csr_path, 'wb') as f:
            f.write(crypto.dump_certificate_request(crypto.FILETYPE_PEM, req))
        
        return True
    except Exception as e:
        print(f"Error generating CSR: {e}", file=sys.stderr)
        return False

def create_p12(cert_path, key_path, p12_path, password=None):
    """Create a PKCS12 (.p12) certificate file."""
    try:
        # Load certificate
        with open(cert_path, 'rb') as f:
            cert_data = f.read()
        cert = crypto.load_certificate(crypto.FILETYPE_PEM, cert_data)
        
        # Load private key
        with open(key_path, 'rb') as f:
            key_data = f.read()
        key = crypto.load_privatekey(crypto.FILETYPE_PEM, key_data)
        
        # Create PKCS12
        p12 = crypto.PKCS12()
        p12.set_certificate(cert)
        p12.set_privatekey(key)
        
        # Export to P12
        p12_data = p12.export(passphrase=password.encode() if password else None)
        
        with open(p12_path, 'wb') as f:
            f.write(p12_data)
        
        return True
    except Exception as e:
        print(f"Error creating P12: {e}", file=sys.stderr)
        return False

def parse_certificate(cert_path):
    """Parse certificate information."""
    try:
        with open(cert_path, 'rb') as f:
            cert_data = f.read()
        
        cert = crypto.load_certificate(crypto.FILETYPE_PEM, cert_data)
        
        # Extract certificate info
        subject = cert.get_subject()
        issuer = cert.get_issuer()
        
        info = {
            'serial_number': str(cert.get_serial_number()),
            'subject': {
                'common_name': subject.CN,
                'organization': subject.O,
                'organizational_unit': subject.OU,
                'country': subject.C,
                'state': subject.ST,
                'locality': subject.L,
                'email': subject.emailAddress,
            },
            'issuer': {
                'common_name': issuer.CN,
                'organization': issuer.O,
                'organizational_unit': issuer.OU,
                'country': issuer.C,
            },
            'not_before': cert.get_notBefore().decode(),
            'not_after': cert.get_notAfter().decode(),
            'version': cert.get_version(),
            'signature_algorithm': cert.get_signature_algorithm().decode(),
        }
        
        return info
    except Exception as e:
        print(f"Error parsing certificate: {e}", file=sys.stderr)
        return None

def main():
    parser = argparse.ArgumentParser(description='Certificate Generator for QuikApp')
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # CSR generation command
    csr_parser = subparsers.add_parser('generate-csr', help='Generate CSR and private key')
    csr_parser.add_argument('--common-name', required=True, help='Common Name')
    csr_parser.add_argument('--organization', required=True, help='Organization')
    csr_parser.add_argument('--organizational-unit', required=True, help='Organizational Unit')
    csr_parser.add_argument('--country', required=True, help='Country (2-letter code)')
    csr_parser.add_argument('--state', required=True, help='State/Province')
    csr_parser.add_argument('--locality', required=True, help='Locality/City')
    csr_parser.add_argument('--email', required=True, help='Email address')
    csr_parser.add_argument('--key-path', required=True, help='Output path for private key')
    csr_parser.add_argument('--csr-path', required=True, help='Output path for CSR')
    
    # P12 creation command
    p12_parser = subparsers.add_parser('create-p12', help='Create P12 certificate')
    p12_parser.add_argument('--cert-path', required=True, help='Path to certificate file')
    p12_parser.add_argument('--key-path', required=True, help='Path to private key file')
    p12_parser.add_argument('--p12-path', required=True, help='Output path for P12 file')
    p12_parser.add_argument('--password', help='Password for P12 file (optional)')
    
    # Certificate parsing command
    parse_parser = subparsers.add_parser('parse-cert', help='Parse certificate information')
    parse_parser.add_argument('--cert-path', required=True, help='Path to certificate file')
    
    args = parser.parse_args()
    
    if args.command == 'generate-csr':
        success = generate_csr(
            args.common_name,
            args.organization,
            args.organizational_unit,
            args.country,
            args.state,
            args.locality,
            args.email,
            args.key_path,
            args.csr_path
        )
        if success:
            print(json.dumps({
                'success': True,
                'key_path': args.key_path,
                'csr_path': args.csr_path
            }))
        else:
            print(json.dumps({'success': False, 'error': 'Failed to generate CSR'}))
            sys.exit(1)
    
    elif args.command == 'create-p12':
        success = create_p12(
            args.cert_path,
            args.key_path,
            args.p12_path,
            args.password
        )
        if success:
            print(json.dumps({
                'success': True,
                'p12_path': args.p12_path
            }))
        else:
            print(json.dumps({'success': False, 'error': 'Failed to create P12'}))
            sys.exit(1)
    
    elif args.command == 'parse-cert':
        info = parse_certificate(args.cert_path)
        if info:
            print(json.dumps({'success': True, 'info': info}))
        else:
            print(json.dumps({'success': False, 'error': 'Failed to parse certificate'}))
            sys.exit(1)
    
    else:
        parser.print_help()
        sys.exit(1)

if __name__ == '__main__':
    main() 