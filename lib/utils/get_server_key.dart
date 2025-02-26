import 'package:googleapis_auth/auth_io.dart';

class GetServerKey {
  Future<String> getServerKeyToken() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": "paksolarmarkt",
        "private_key_id": "1f6260c94819ff75ae0fd121e609fd8abe96778f",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDA8/npesywSe1L\nt6S/1nM6guoDqqVgSs9Hz7tshZEfrPirLjmxlCGE7qPOJC9Df0dEy5rqzoaUaoPK\nQst/ubVXufebkmWMlPSVR9hRDDvey6bdQZ8AhPnGS1iPV6U3aEmt+b9J4lrpNGxv\nA5WWeJZVFJOZeLC8ydNunEvX3JcqaKAthFMdYI7cHNE/5LAO3zfgIx/u/kOtKgXM\nL5MHTzvOCscQESLFNJXwUMJuwDk8E7i9xug1da+LpzpNod5Ruqjo+nDP8ODq0WgO\nCUi3ReWjvymZUZh4XQLyBGubhk1ZxPy9D9hN2ywEo+KvG/ibYbhlyNT8uKrkeY28\nZUXG/CVlAgMBAAECggEAOMILy4BR4bF9Wf6FOeENODL2P2ndB7w5yPf0O/H2RIkP\nBNuuIOxgB8hi6up99K7l+fiic1uY/uNuLPsE/WdVTp7nlR21PWs7nwXpPb4JhnoF\ndaQt72suRgQ34sJ3WRsWQVTrzgIFl//Rvb4iLIcAQbqxyD1WT9JWnXzgWnkLBnAI\n9SfKQrPaOeG/5YAWACjPI6ThpjkuP0N5jKRjn0likNJrRHLIDY5mg8wCYOuv83yJ\nX1QotvHPORx6e8TJkqql8aUTftx3KVwtBuYDVafNwIVjEbvK1hgwvXLmwpmYiw8A\nZ6xZKfAT5R/9tm1dr5TFNElIe7fefn282jndUNyz6QKBgQDJFwnFU2ZYlONpo6PD\nMaViHcEuPoVOWTJgOstQVXzFK/a0HTuG+U5L8hRimEh2aG7pW7Z42eQTgQFvii+L\nqfhpdkcii8UeV6T509ic/6yFLMFfgPQcPC7P4xCmtbxHNwDC26U2igXZj/3BUNbD\nzgJ0TZBXkrPdFqBak8XwipLRdwKBgQD1pCIe8+K4w9ab6h/JWhFlMnylId4PsejQ\n79XgHN3967Z6zvPumizvNm1feus6HPdRGQ9zpUMt4+AzPg0yIMi/I4PiF98Vpy5d\nPfKZji3Li6OTIVSiNzNJo14N96iSQE5P8SEbKUxBJmG6+ocfphy50MwzFuKX6Vw5\nFO7NiZ4XAwKBgQCGhCLFHUUZfH+j6xNhP5SiTcUsaiZCguhv9uSKmKUeQIqHcgag\nA6WcqBN64OOYUcPf1rn5ncg0Q9fyBT5I7yp9YeGz+kuiQH7boBsG6wE9FPNGL70c\nJiYqanp5CpkoCmM39jZOhYXkQ6474xfHY8fAhSJJcplfDAO4k6GVhx0vgQKBgQDu\ni8KHBJk8jRKwvyC3TTxvZiQdyVH5M/DAVukAh4gduvavNKM3J4pTlCuK+bfN66tR\nmmCjEe63dgCYQr5V2/iXhknhGwWN5Zjk++/Ip4ZZkPX9P/UMw0aPUJNaRRPzU3e5\nspVP5z8iVb+68OigF5T17osfYi4TEJB67pUqDWb1OQKBgQDIBXm/9AWkEVN9y5cV\nWgiM1cegWR9P0J6nxZJYIhOu6nJol3lm3KRar1muotkqpQuarNC4ndKc4R3vcIfA\nU6Xl+0hI9hxKoj3CQn9WqkpI6f/VwTfZg1sH5YBIpYMgERW/6+LopaJuo6puK3pM\nvpsmw4t8RdMNos/dowd5KU12pQ==\n-----END PRIVATE KEY-----\n",
        "client_email":
            "firebase-adminsdk-wl8px@paksolarmarkt.iam.gserviceaccount.com",
        "client_id": "105302126845719065866",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-wl8px%40paksolarmarkt.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
      }),
      scopes,
    );
    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
}
