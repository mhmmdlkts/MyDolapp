const functions = require("firebase-functions");
const admin = require('firebase-admin');

admin.initializeApp();

const region = 'europe-west1';

exports.onNewUserCreate = functions.region(region).auth.user().onCreate(async (user) => {
    await admin.firestore().collection('users').doc(user.uid).set({email: user.email});
    await createNewWardrobe(user.uid, 'My Wardrobe')
});

async function createNewWardrobe(uid, wardrobeName) {
    const wardrobe = {
        name: wardrobeName,
        create_time: admin.firestore.Timestamp.now()
    }
    await admin.firestore().collection('users').doc(uid).collection('wardrobes').add(wardrobe).then(async function(docRef) {
        await addNewCloth(uid, docRef.id, 'My T-shirt')
    });
}

async function addNewCloth(uid, wardrobeId, itemName) {
    const item = {
        name: itemName,
        create_time: admin.firestore.Timestamp.now(
    }
    await admin.firestore().collection('users').doc(uid).collection('wardrobes').doc(wardrobeId).collection('items').add(item);
}