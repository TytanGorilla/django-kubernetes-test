#!/usr/bin/env python3

import secrets

def generate_secret_key():
    return ''.join(secrets.choice(
        'abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)'
    ) for _ in range(50))

if __name__ == "__main__":
    print("\nYour Django secret key:")
    print(generate_secret_key())
    print("\nCopy and paste this key into your .env file as:")
    print("DJANGO_SECRET_KEY=<your-generated-key>")
