const functions = require("firebase-functions");
const admin = require('firebase-admin');
const spawn = require('child-process-promise').spawn;
const path = require('path');
const os = require('os');
const fs = require('fs');

admin.initializeApp();

const region = 'europe-west1';

exports.onNewUserCreate = functions.region(region).auth.user().onCreate(async (user) => {
    await admin.firestore().collection('users').doc(user.uid).set({email: user.email});
    await createNewWardrobe(user.uid, 'My Wardrobe')
});


exports.onNewItemUploaded = functions.region(region).storage.object().onFinalize(async (object) => {

    const fileBucket = object.bucket;
    const filePath = object.name;
    const contentType = object.contentType;
    const fileName = path.basename(filePath);

    if (filePath.split('/')[1] != 'Items' || fileName != 'original.png') {
        return;
    }
    if (!contentType.startsWith('image/')) {
        return functions.logger.log('This is not an image.');
    }

    const bucket = admin.storage().bucket(fileBucket);
    const tempFilePath = path.join(os.tmpdir(), fileName);
    const metadata = {
        contentType: contentType,
    };
    await bucket.file(filePath).download({destination: tempFilePath});

    await spawn('convert', [tempFilePath, '-thumbnail', '600x600>', tempFilePath]);

    const thumbFileName = '600x600.png';
    const thumbFilePath = path.join(path.dirname(filePath), thumbFileName);
    await bucket.upload(tempFilePath, {
        destination: thumbFilePath,
        metadata: metadata,
    });
    return fs.unlinkSync(tempFilePath);
});

async function createNewWardrobe(uid, wardrobeName) {
    const wardrobe = {
        name: wardrobeName,
        create_time: admin.firestore.Timestamp.now()
    }
    await admin.firestore().collection('users').doc(uid).collection('wardrobes').add(wardrobe).then(async function(docRef) {
        await addNewCloth(uid, docRef.id, 'tShirt')
    });
}

async function addNewCloth(uid, wardrobeId, itemType) {
    const item = {
        type: itemType,
        create_time: admin.firestore.Timestamp.now()
    }
    await admin.firestore().collection('users').doc(uid).collection('wardrobes').doc(wardrobeId).collection('items').add(item);
}
