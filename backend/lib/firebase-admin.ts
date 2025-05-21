import * as admin from 'firebase-admin';

// Load Firebase service account credentials from environment variables
function loadServiceAccountFromEnv() {
  try {
    // Try to parse the service account from environment variables
    const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT
      ? JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT)
      : null;

    return serviceAccount;
  } catch (error) {
    console.error(
      'Error parsing Firebase service account from environment:',
      error
    );
    return null;
  }
}

// Initialize Firebase Admin SDK
export function initFirebaseAdmin() {
  if (admin.apps.length === 0) {
    const serviceAccount = loadServiceAccountFromEnv();

    // If we have service account credentials, use them
    if (serviceAccount) {
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
    }
    // Otherwise use application default credentials or service account path
    else {
      admin.initializeApp({
        // Try to use application default credentials
        credential: admin.credential.applicationDefault(),
        // If there's a specific path to the service account file
        // credential: admin.credential.cert(require(process.env.FIREBASE_SERVICE_ACCOUNT_PATH)),
      });
    }
  }

  return admin;
}

// Get Firebase admin instance (initialize if needed)
export function getFirebaseAdmin() {
  if (admin.apps.length === 0) {
    initFirebaseAdmin();
  }

  return admin;
}

export default getFirebaseAdmin();
