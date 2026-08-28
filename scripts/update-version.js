const admin = require('firebase-admin');
const serviceAccount = require('/tmp/sa.json');

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

async function main() {
  await db.doc('app_versions/com.davidstore.davidstore_livreur').set({
    latestVersionCode: parseInt(process.env.VERSION_CODE, 10),
    latestVersionName: process.env.VERSION_NAME,
    downloadUrl: process.env.DOWNLOAD_URL,
    sizeBytes: parseInt(process.env.FILE_SIZE, 10),
    forceUpdate: false,
    message: process.env.RELEASE_NOTES || '',
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });
  console.log('Firestore version doc updated.');
}

main().catch((err) => { console.error(err); process.exit(1); });
